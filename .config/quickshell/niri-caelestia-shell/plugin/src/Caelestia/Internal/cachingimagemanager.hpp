#pragma once

#include <QtQuick/qquickitem.h>
#include <qmap.h>
#include <qmutex.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtimer.h>

namespace caelestia {

class CachingImageManager : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickItem* item READ item WRITE setItem NOTIFY itemChanged REQUIRED)
    Q_PROPERTY(QUrl cacheDir READ cacheDir WRITE setCacheDir NOTIFY cacheDirChanged REQUIRED)

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QUrl cachePath READ cachePath NOTIFY cachePathChanged)

public:
    explicit CachingImageManager(QObject* parent = nullptr)
        : QObject(parent)
        , m_item(nullptr) {
        m_debounceTimer.setSingleShot(true);
        m_debounceTimer.setInterval(150);
        connect(&m_debounceTimer, &QTimer::timeout, this, [this]() { updateSource(); });
    }

    [[nodiscard]] QQuickItem* item() const;
    void setItem(QQuickItem* item);

    [[nodiscard]] QUrl cacheDir() const;
    void setCacheDir(const QUrl& cacheDir);

    [[nodiscard]] QString path() const;
    void setPath(const QString& path);

    [[nodiscard]] QUrl cachePath() const;

    Q_INVOKABLE void updateSource();
    Q_INVOKABLE void updateSource(const QString& path);

signals:
    void itemChanged();
    void cacheDirChanged();

    void pathChanged();
    void cachePathChanged();
    void usingCacheChanged();

private:
    // LRU cache entry for tracking disk cached images
    struct CacheEntry {
        QString filePath;
        qint64 fileSize;
        qint64 lastAccess; // msecs since epoch
    };

    QString m_shaPath;

    QQuickItem* m_item;
    QUrl m_cacheDir;

    QString m_path;
    QUrl m_cachePath;

    QMetaObject::Connection m_widthConn;
    QMetaObject::Connection m_heightConn;
    QTimer m_debounceTimer;

    // LRU cache tracking (shared across all instances)
    static QMap<QString, CacheEntry> s_cacheEntries;
    static qint64 s_totalCacheSize;
    static QMutex s_cacheMutex;
    static constexpr qint64 MAX_CACHE_BYTES = 100 * 1024 * 1024; // 100 MB

    [[nodiscard]] qreal effectiveScale() const;
    [[nodiscard]] QSize effectiveSize() const;

    void createCache(const QString& path, const QString& cache, const QString& fillMode, const QSize& size);
    void trackCacheEntry(const QString& cachePath, qint64 fileSize);
    void evictIfNeeded();
    [[nodiscard]] static QString sha256sum(const QString& path);
};

} // namespace caelestia
