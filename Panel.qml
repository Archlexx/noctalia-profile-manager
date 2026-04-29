import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  // Plugin API
  property var pluginApi: null

  // SmartPanel integration
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  // Preferred dimensions
  property real contentPreferredWidth: Math.round(380 * Style.uiScaleRatio)
  property real contentPreferredHeight: Math.round(480 * Style.uiScaleRatio)

  // Shortcut to service
  readonly property var service: pluginApi?.mainInstance

  readonly property bool defaultIncludeWallpapers:
    pluginApi?.pluginSettings?.includeWallpapers ??
    pluginApi?.manifest?.metadata?.defaultSettings?.includeWallpapers ??
    true

  property string searchQuery: ""
  property string sortField: "name"   // "name" | "date"
  property string sortDir: "asc"       // "asc"  | "desc"

  ListModel { id: profilesModel }

  function _rebuildProfiles() {
    var all = service?.profiles ?? []
    var q = searchQuery.trim().toLowerCase()
    var filtered = q === "" ? all.slice() : all.filter(function(p) { return p.toLowerCase().indexOf(q) !== -1 })
    var meta = service?.profileMeta ?? {}
    var asc = sortDir === "asc"
    var field = sortField
    filtered.sort(function(a, b) {
      var cmp = field === "date"
        ? ((meta[a]?.savedAt ?? "") < (meta[b]?.savedAt ?? "") ? -1 : (meta[a]?.savedAt ?? "") > (meta[b]?.savedAt ?? "") ? 1 : 0)
        : a.localeCompare(b)
      return asc ? cmp : -cmp
    })
    profilesModel.clear()
    for (var i = 0; i < filtered.length; i++)
      profilesModel.append({ "profileName": filtered[i] })
  }

  onSortFieldChanged:   Qt.callLater(_rebuildProfiles)
  onSortDirChanged:     Qt.callLater(_rebuildProfiles)
  onSearchQueryChanged: Qt.callLater(_rebuildProfiles)
  onServiceChanged:     Qt.callLater(_rebuildProfiles)

  Connections {
    target: service
    function onProfilesChanged()    { root._rebuildProfiles() }
    function onProfileMetaChanged() { root._rebuildProfiles() }
  }

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // ── Header ──────────────────────────────────────────────────────────────
      NBox {
        id: headerBox
        Layout.fillWidth: true
        Layout.preferredHeight: headerRow.implicitHeight + Style.margin2M

        RowLayout {
          id: headerRow
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NIcon {
            icon: pluginApi?.pluginSettings?.icon || "bookmark"
            pointSize: Style.fontSizeXXL
            color: Color.mPrimary
          }

          NLabel {
            label: pluginApi?.tr("panel.title")
            Layout.fillWidth: true
          }

          NIconButton {
            icon: "settings"
            tooltipText: I18n.tr("tooltips.open-settings")
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: {
              var screen = pluginApi?.panelOpenScreen
              if (screen && pluginApi?.manifest)
                BarService.openPluginSettings(screen, pluginApi.manifest)
            }
          }

          NIconButton {
            icon: "close"
            tooltipText: I18n.tr("common.close")
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: pluginApi?.closePanel(pluginApi.panelOpenScreen)
          }
        }
      }

      // ── Save bar ─────────────────────────────────────────────────────────────
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: saveRow.implicitHeight + Style.margin2M

        RowLayout {
          id: saveRow
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NTextInput {
            id: saveInput
            Layout.fillWidth: true
            placeholderText: pluginApi?.tr("panel.save-placeholder")
            Keys.onReturnPressed: {
              if (saveBtn.enabled) saveBtn.clicked()
            }
          }

          NButton {
            id: saveBtn
            text: pluginApi?.tr("panel.save-button")
            icon: "bookmark-plus"
            enabled: saveInput.text.trim() !== "" && !(service?.isBusy ?? false)
            onClicked: {
              var name = saveInput.text.trim()
              var err = service?.validateName(name) || ""
              if (err) { saveError.text = err; return }
              service?.saveProfile(name, function(ok, msg) {
                if (ok) {
                  saveInput.text = ""
                  saveError.text = ""
                } else {
                  saveError.text = msg
                }
              })
            }
          }
        }
      }

      NText {
        id: saveError
        visible: text !== ""
        color: Color.mError
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.leftMargin: Style.marginS
      }

      // ── Import button ─────────────────────────────────────────────────────────
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: importRow.implicitHeight + Style.margin2M

        RowLayout {
          id: importRow
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NButton {
            id: importBtn
            Layout.fillWidth: true
            text: pluginApi?.tr("panel.import-button")
            icon: "folder-plus"
            enabled: !(service?.isBusy ?? false)
            onClicked: importPicker.openFilePicker()
          }

          NFilePicker {
            id: importPicker
            selectionMode: "folders"
            onAccepted: paths => {
              if (paths.length > 0) {
                importError.text = ""
                service?.importProfile(paths[0], function(ok, msg) {
                  if (!ok) importError.text = msg
                })
              }
            }
          }
        }
      }

      NText {
        id: importError
        visible: text !== ""
        color: Color.mError
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.leftMargin: Style.marginS
      }


      // ── Search + sort ─────────────────────────────────────────────────────────
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        visible: (service?.profiles?.length ?? 0) > 0

        NTextInput {
          Layout.fillWidth: true
          placeholderText: pluginApi?.tr("panel.search-placeholder")
          inputIconName: "search"
          onTextChanged: root.searchQuery = text
        }

        NIconButton {
          icon: root.sortField === "name" ? "a-b" : "clock"
          tooltipText: pluginApi?.tr("panel.sort-field-" + root.sortField)
          baseSize: Math.round(Style.fontSizeXXL * Style.uiScaleRatio)
          colorBg: "transparent"
          colorFg: Color.mOnSurfaceVariant
          onClicked: root.sortField = root.sortField === "name" ? "date" : "name"
        }

        NIconButton {
          icon: root.sortDir === "asc" ? "arrow-up" : "arrow-down"
          tooltipText: pluginApi?.tr("panel.sort-dir-" + root.sortDir)
          baseSize: Math.round(Style.fontSizeXXL * Style.uiScaleRatio)
          colorBg: "transparent"
          colorFg: Color.mOnSurfaceVariant
          onClicked: root.sortDir = root.sortDir === "asc" ? "desc" : "asc"
        }
      }

      // ── Profile list ─────────────────────────────────────────────────────────
      NScrollView {
        id: profileScrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalPolicy: ScrollBar.AlwaysOff
        verticalPolicy: ScrollBar.AsNeeded
        reserveScrollbarSpace: false
        gradientColor: Color.mSurface

        ColumnLayout {
          id: listColumn
          width: profileScrollView.availableWidth
          spacing: Style.marginM

          // Empty state
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: emptyCol.implicitHeight + Style.margin2XL
            visible: (service?.profiles?.length ?? 0) === 0

            ColumnLayout {
              id: emptyCol
              anchors.centerIn: parent
              spacing: Style.marginM

              NIcon {
                icon: "bookmark-off"
                pointSize: Style.fontSizeXXL * 2
                color: Color.mOnSurfaceVariant
                Layout.alignment: Qt.AlignHCenter
              }

              NText {
                text: pluginApi?.tr("panel.empty")
                pointSize: Style.fontSizeM
                color: Color.mOnSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.maximumWidth: Math.round(260 * Style.uiScaleRatio)
              }
            }
          }

          // Profile rows
          Repeater {
            model: profilesModel

            delegate: ProfileRow {
              profileName: model.profileName
              includeWallpapers: root.defaultIncludeWallpapers
              service: root.service
              pluginApi: root.pluginApi
              panelRef: root
              Layout.fillWidth: true
            }
          }
        }
      }
    }
  }

  // Refresh list each time the panel opens
  onVisibleChanged: {
    if (visible)
      service?.listProfiles()
  }
}
