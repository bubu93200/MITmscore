// Fichier à ajouter pour créer un plugin QML
//
#include <QtQml>
#include "types.h"
#include "score.h"

class MscoreQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri)
    {
        Q_ASSERT(uri == QLatin1String("Mscore"));
        qmlRegisterType<MScore>(uri, 1, 0, "MScore");
    }
};
