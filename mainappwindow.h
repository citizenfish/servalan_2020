#ifndef MAINAPPWINDOW_H
#define MAINAPPWINDOW_H

#include <QMainWindow>

class mainAppWindow : public QMainWindow
{
    Q_OBJECT

public:
    mainAppWindow(QWidget *parent = nullptr);
    ~mainAppWindow();
};
#endif // MAINAPPWINDOW_H
