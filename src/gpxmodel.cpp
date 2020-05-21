#include "headers/gpxmodel.h"

GPXModel::GPXModel(QObject *parent): QAbstractListModel(parent)
{
    connect(this, &QAbstractListModel::rowsInserted, this, &GPXModel::pathChanged);
    connect(this, &QAbstractListModel::rowsRemoved, this, &GPXModel::pathChanged);
    connect(this, &QAbstractListModel::dataChanged, this, &GPXModel::pathChanged);
    connect(this, &QAbstractListModel::modelReset, this, &GPXModel::pathChanged);
    connect(this, &QAbstractListModel::rowsMoved, this, &GPXModel::pathChanged);


}


Q_INVOKABLE int GPXModel::addMarker(const QGeoCoordinate coordinate, bool appendFlag) {

    int index = 0;

    //This will append the coordinate at the appropriate position on the line
    if(!appendFlag) {
        index = indexCoordinate(m_trackpoints,coordinate);
    } else {
        index = m_trackpoints.count();
        trackpoint item ={coordinate,0, QDateTime::currentDateTime()};
        m_trackpoints.append(item);
    }

    setEditLocation(index);
    return index;
}


Q_INVOKABLE QGeoCoordinate GPXModel::deleteMarkerAtIndex(int index){


    if(index < 0 || index >= m_trackpoints.count()) {
        qDebug() <<"Index out of range so do nothing " << index;
        return QGeoCoordinate();
       }

    // We return it for undo purposes
    QGeoCoordinate ret_var = m_trackpoints[index].latlon;
    m_trackpoints.removeAt(index);
    setEditLocation(index - 1);

    return ret_var;
}

Q_INVOKABLE int GPXModel::deleteMarkerRange(const int index1, const int index2){

    int undoIndex = undo_trackpoints.count();
    beginRemoveRows(QModelIndex(),index1, index2);
    undo_trackpoints.append(m_trackpoints.mid(index1, index2 - index1 + 1));
    m_trackpoints.remove(index1, index2 - index1 + 1);
    endRemoveRows();

    setEditLocation(index1);

    return undoIndex;
}

Q_INVOKABLE int GPXModel::insertMarkerRangeUndo(const int index, const int count, int undo_pointer) {

    if(index < 0 || undo_pointer + count > undo_trackpoints.count() -1 ){
        qDebug() << "Index out of range " << undo_pointer << " : " << count;
    }

    beginInsertRows(QModelIndex(), index, index + count);
        for(int i = index; i < index + count; i++){
            m_trackpoints.insert(i,undo_trackpoints[undo_pointer++]);
        }
    endInsertRows();

    setEditLocation(index);
    return index;
}

Q_INVOKABLE void GPXModel::clearMarkers( ){
            beginRemoveRows(QModelIndex(),0,rowCount());
            edit_markers.clear();
            m_trackpoints.clear();
            m_waypoints.clear();
            endRemoveRows();
}

Q_INVOKABLE int GPXModel::setNumDragHandles(int num){
        numDragHandles = num;
        return numDragHandles;
}

/*
 * Forces a redraw from the current index. I use this for repainting markers after selecting a line segment
 *
 */

Q_INVOKABLE void GPXModel::forceRedraw(const int index1, const int range){

    setEditLocation(index1, range);
}

/*
 * Used when we click on a line to show the nearest drag handles to the line
 *
 */

Q_INVOKABLE int GPXModel::setEditLocationFromCoordinate(const QGeoCoordinate coordinate) {

    int index = indexCoordinate(m_trackpoints, coordinate, false);
    setEditLocation(index, numDragHandles);
    return index;
}

/*
 * This function creates the edit_markers vector which holds the drag handles
 * The vector is centered around index and creates "range" makers
 *
 */

Q_INVOKABLE void GPXModel::setEditLocation(const int pathIndex, int range) {

    int pathCount = m_trackpoints.count() - 1;

    if(pathIndex < 0 || pathIndex > pathCount){
        return;
    }

    if(range == -1) {
        range = numDragHandles;
    }

    //we are working out a range of drag handles to extract from the trackpoints and display for editing
    float dHeight = 0;
    int lower_index = std::max(0, pathIndex - (int)round(range/2));
    int add_range = std::min(range, pathCount - lower_index);

    edit_marker_offset = lower_index;

    //here we clear and refill the markers array
    beginRemoveRows(QModelIndex(),0,rowCount());
    edit_markers.clear();
    endRemoveRows();

    //Remember the subtle difference here. beginInsertRows wants a POSITION, mid wants a COUNT
    beginInsertRows(QModelIndex(), 0, add_range );
    edit_markers = m_trackpoints.mid(lower_index, add_range + 1);
    endInsertRows();

    //Update path length and height gain
    pathLength = 0;
    totalHeightGain = 0;
    totalDescent = 0;

    for(int i = 1; i < m_trackpoints.count(); i++) {
        pathLength += latlondist_vincenty(m_trackpoints[i].latlon, m_trackpoints[i-1].latlon);
        dHeight = m_trackpoints[i].ele - m_trackpoints[i-1].ele;
        if(dHeight > 0){
            totalHeightGain += dHeight;
        }
        if(dHeight < 0){
            totalDescent += dHeight;
        }
    }

}

Q_INVOKABLE QGeoCoordinate GPXModel::updateMarkerLocation(const QGeoCoordinate &coordinate, int index) {


    m_trackpoints[index].latlon = coordinate;
    m_trackpoints = addHeight(m_trackpoints,index,1); //need to update the height value as well
    setEditLocation(index);
    return coordinate;
}

Q_INVOKABLE bool GPXModel::saveToFile(QUrl fileName){

    //used for save as we do not provide filename
    if(fileName.isEmpty() && !m_fileName.isEmpty())
        fileName  = m_fileName;

    QFile file(fileName.toLocalFile());

    if(file.open(QIODevice::WriteOnly)){
        QXmlStreamWriter writer;
            writer.setDevice(&file);
            writer.setAutoFormatting(true);
            writer.setAutoFormattingIndent(2);
            writer.writeStartDocument();
            writer.writeStartElement("gpx");
            writer.writeAttribute("version", "1.0");
            writer.writeAttribute("creator", "servalan 2020 core");
            writer.writeAttribute("xmlns", "http://www.topografix.com/GPX/1/0");

            //Now bang out our track
            writer.writeStartElement("trk");
            writer.writeTextElement("name", m_trackName);
            writer.writeStartElement("trkseg");


            foreach(const trackpoint &trkpoint, m_trackpoints) {
                writer.writeStartElement("trkpt");
                writer.writeAttribute("lat", QString::number(trkpoint.latlon.latitude()));
                writer.writeAttribute("lon", QString::number(trkpoint.latlon.longitude()));
                if(trkpoint.ele >= 0) {
                    writer.writeTextElement("ele", QString::number(trkpoint.ele));
                }
                writer.writeEndElement();
            }

            writer.writeEndDocument();
            m_fileName = fileName;
            return true;

    }

    return false;
}

Q_INVOKABLE QString GPXModel::getFileName() {  return m_fileName.fileName();};
Q_INVOKABLE QString GPXModel::getTrackName() {  return m_trackName;};
Q_INVOKABLE QString GPXModel::setTrackName(QString trackname ) {  m_trackName = trackname; return m_trackName;};

Q_INVOKABLE bool GPXModel::loadFromFile(const QUrl fileName) {

    QFile file(fileName.toLocalFile());
    int pointCounter = 0;
    QVector<trackpoint> temp_load;

    if(!file.exists()) {
        qWarning() << "Does not exist: " << fileName.toLocalFile();
        return false;
    }

    //Keep a copy for save operation
    m_fileName = fileName;

    if(file.open(QIODevice::ReadOnly)){

        QXmlStreamReader reader;
        reader.setDevice(&file);

        while(!reader.atEnd()) {
            reader.readNext();
            if(reader.isStartElement()){

                if(reader.name() == "name" && m_trackName == ""){
                        m_trackName = reader.readElementText();
                        qDebug() << "Set track name to " << m_trackName;
                }

                //Obvs this needs rewriting as it ignores trksegs and simply lineraly ingests points assuming a single track
                if(reader.name() == "trkpt" || reader.name() =="rtept" || reader.name() == "wpt") {


                    QGeoCoordinate coord;
                    float ele;
                    QString name,cmt,desc,sym;
                    QDateTime time;

                    QXmlStreamAttributes attributes=reader.attributes();
                   //make a trackpoint
                   if(attributes.hasAttribute("lat") && attributes.hasAttribute("lon")){
                        coord.setLongitude(attributes.value("lon").toFloat());
                        coord.setLatitude(attributes.value("lat").toFloat());

                   }

                   //read through trackpoint/waypoint and pick up sub-elements
                   while(!reader.isEndElement()){
                       if(reader.name()=="ele"){
                           ele=reader.readElementText().toFloat();
                       }
                       if(reader.name()=="name"){
                           name=reader.readElementText();
                       }
                       if(reader.name()=="cmt"){
                           cmt=reader.readElementText();
                       }
                       if(reader.name()=="desc"){
                           desc=reader.readElementText();
                       }
                       if(reader.name()=="sym"){
                           sym=reader.readElementText();
                       }
                       if(reader.name()=="time"){
                           time=QDateTime::fromString(reader.readElementText());
                       }
                       reader.readNext();
                   }

                   if(reader.name() != "wpt") {
                       trackpoint trackPoint;
                       //set its index in the gpx file, we use this on marker sampling reduction
                       trackPoint = {coord,ele,time};
                       //Increment the trackpoint counter and load the trackPoint array
                       ++pointCounter;
                       temp_load.append(trackPoint);
                   } else {
                       waypoint waypoint = {coord,name,cmt,desc,sym,ele};
                       m_waypoints.append(waypoint);
                   }

               }



            }
        }

        file.close();

    }

    if(pointCounter == 0) {

        return false;
    }
    beginInsertRows(QModelIndex(), 0, 0);
    m_trackpoints = temp_load;
    endInsertRows();
    emit fileLoaded();
    return true;

}


int GPXModel::rowCount(const QModelIndex &parent)  const {
    if(parent.isValid()) return 0;
    return edit_markers.count();
}


QVariant GPXModel::data(const QModelIndex &index, int role) const {

    if (index.row() < 0 || index.row() >= edit_markers.count())
        return QVariant();
    if(role == Qt::DisplayRole)
        return QVariant::fromValue(index.row());
    else if(role == GPXModel::positionRole)
        return QVariant::fromValue(edit_markers[index.row()].latlon);
    else if(role == GPXModel::itemRole)
        return QVariant::fromValue(index.row());
    return QVariant();
}

/*
 * positionRole is used for displaying markers
 * itemRole is used for displaying the index value of a marker so we can find its corresponding line coordinate
 */

QHash<int, QByteArray> GPXModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[positionRole] = "positionRole";
    roles[itemRole]     = "itemRole";

    return roles;
}

QVariantList GPXModel::path() const {
    QVariantList path;
    for(const trackpoint & coord: m_trackpoints)  {
        path << QVariant::fromValue(coord.latlon);

    }
    return path;
}

