#include "gpxmodel.h"

Q_INVOKABLE int GPXModel::addMarker(const QGeoCoordinate &coordinate, float elevation, QDateTime dateTime) {

    gpxCoordinate item ={coordinate,elevation, dateTime, m_coordinates.count()};

    m_coordinates.append(item);
    setEditLocation(m_coordinates.count() - 1);

    return m_coordinates.count() - 1;
}

Q_INVOKABLE int GPXModel::addMarkerAtIndex(const QGeoCoordinate &coordinate, int index, float elevation, QDateTime dateTime) {

    if(index >= m_coordinates.count()){
        qDebug() << "Index out of range so appending " << index;
        return addMarker(coordinate,elevation,dateTime);
    }

    index++;
    gpxCoordinate item ={coordinate,elevation, dateTime, index};

    m_coordinates.insert(index,1,item);
    reindex(index);
    setEditLocation(index);

    return index + 1;
}

Q_INVOKABLE QGeoCoordinate GPXModel::deleteMarkerAtIndex(int index){

    if(index < 0 || index >= m_coordinates.count()) {
        qDebug() <<"Index out of range so do nothing " << index;
        return QGeoCoordinate();
       }
    QGeoCoordinate ret_var = m_coordinates[index].latlon;

    m_coordinates.removeAt(index);
    reindex(index);
    setEditLocation(index - 1);

    return ret_var;
}
/*
 * This function creates the edit_markers vector which holds the drag handles
 * The vector is centered around index and creates "range" makers
 *
 */

Q_INVOKABLE void GPXModel::setEditLocation(const int pathIndex, int range) {

    if(range == -1) range = numDragHandles;

    int pathCount = m_coordinates.count() - 1;
    if(pathIndex < 0 || pathIndex > pathCount) return;

    int lower_index = std::max(0, pathIndex - (int)round(range/2));
    int add_range = std::min(range, pathCount - lower_index);

    //here we clear and refill the markers array
    beginRemoveRows(QModelIndex(),0,rowCount());
    edit_markers.clear();
    endRemoveRows();

    //Remember the subtle difference here. beginInsertRows wants a POSITION, mid wants a COUNT
    beginInsertRows(QModelIndex(), 0, add_range );
    edit_markers = m_coordinates.mid(lower_index, add_range + 1);
    endInsertRows();

}

Q_INVOKABLE QGeoCoordinate GPXModel::updateMarkerLocation(const QGeoCoordinate &coordinate, int index) {

    m_coordinates[index].latlon = coordinate;
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
            writer.writeStartElement("trkseg");

            foreach(const gpxCoordinate &trkpoint, m_coordinates) {
                writer.writeStartElement("trkpt");
                writer.writeAttribute("lat", QString::number(trkpoint.latlon.latitude()));
                writer.writeAttribute("lon", QString::number(trkpoint.latlon.longitude()));
                if(trkpoint.ele >= 0) {
                    writer.writeAttribute("ele", QString::number(trkpoint.ele));
                }
                writer.writeEndElement();
            }

            writer.writeEndDocument();
            m_fileName = fileName;
            return true;

    }

    return false;
}

Q_INVOKABLE bool GPXModel::loadFromFile(const QUrl fileName) {

    QFile file(fileName.toLocalFile());
    int pointCounter = 0;
    QVector<gpxCoordinate> temp_load;

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
                //Obvs this needs rewriting as it ignores trksegs and simply lineraly ingests points assuming a single track
                if(reader.name() == "trkpt" || reader.name() =="rtept") {
                    gpxCoordinate trackPoint;
                    QGeoCoordinate coord;

                    QXmlStreamAttributes attributes=reader.attributes();
                   //make a trackpoint
                   if(attributes.hasAttribute("lat") && attributes.hasAttribute("lon")){
                        coord.setLongitude(attributes.value("lon").toFloat());
                        coord.setLatitude(attributes.value("lat").toFloat());
                        trackPoint.latlon = coord;

                   }

                   //set its index in the gpx file, we use this on marker sampling reduction
                   trackPoint.index = pointCounter;

                   //read through trackpoint and pick up elevation
                   while(!reader.isEndElement()){
                       if(reader.name()=="ele"){
                           trackPoint.ele=reader.readElementText().toFloat();
                       }
                       reader.readNext();
                   }
                   //Increment the trackpoint counter and load the trackPoint array
                   ++pointCounter;
                   temp_load.append(trackPoint);

               }
            }
        }

        file.close();

    }

    if(pointCounter == 0) {

        return false;
    }
    beginInsertRows(QModelIndex(), 0, 0);
    m_coordinates = temp_load;
    endInsertRows();

    return true;

}

void GPXModel::reindex(int index){
    for(int i = index; i < m_coordinates.count(); i++) {
        m_coordinates[i].index = i;
    }
}

int GPXModel::rowCount(const QModelIndex &parent)  const {
    if(parent.isValid()) return 0;
    return edit_markers.count();
}

bool GPXModel::removeRows(int row, int count, const QModelIndex &parent)  {
    if(row + count > m_coordinates.count() || row < 0)
        return false;
    beginRemoveRows(parent, row, row+count-1);
    for(int i = 0; i < count; ++i)
        m_coordinates.removeAt(row + i);
    endRemoveRows();
    return true;
}

bool GPXModel::removeRow(int row, const QModelIndex &parent) {
    return removeRows(row, 1, parent);
}

QVariant GPXModel::data(const QModelIndex &index, int role) const {

    if (index.row() < 0 || index.row() >= edit_markers.count())
        return QVariant();
    if(role == Qt::DisplayRole)
        return QVariant::fromValue(index.row());
    else if(role == GPXModel::positionRole)
        return QVariant::fromValue(edit_markers[index.row()].latlon);
    else if(role == GPXModel::itemRole)
        return QVariant::fromValue(edit_markers[index.row()].index);

    return QVariant();
}

/*
 * positionRole is used for displaying markers
 * itemRole is used for dispalying the index value of a marker so we can find its corresponding line coordinate
 *
 */
QHash<int, QByteArray> GPXModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[positionRole] = "positionRole";
    roles[itemRole]     = "itemRole";

    return roles;
}

QVariantList GPXModel::path() const {
    QVariantList path;
    for(const gpxCoordinate & coord: m_coordinates)  {
        path << QVariant::fromValue(coord.latlon);

    }
    return path;
}
