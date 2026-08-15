import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "murdi.named-workspaces"

  readonly property var focusedMonitor: Hyprland.focusedMonitor

  property var lastFocusedByWorkspace: ({})

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var monitor = root.focusedMonitor
    var values = Hyprland.workspaces.values
    var ids = []

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (workspace.id <= 0) continue
      if (monitor && workspace.monitor !== monitor) continue
      if (workspace.focused || workspace.toplevels.values.length > 0) {
        ids.push(workspace.id)
      }
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function titleOf(toplevel) {
    if (!toplevel) return ""
    if (toplevel.title) return toplevel.title
    if (toplevel.wayland && toplevel.wayland.appId) return toplevel.wayland.appId
    return ""
  }

  function containsAddress(toplevels, address) {
    if (!address) return false
    for (var i = 0; i < toplevels.length; i++) {
      if (toplevels[i].address === address) return true
    }

    return false
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  Connections {
    target: Hyprland

    function onActiveToplevelChanged() {
      var toplevel = Hyprland.activeToplevel
      if (!toplevel) return
      var workspace = toplevel.workspace
      if (!workspace || workspace.id <= 0) return

      var next = {}
      for (var key in root.lastFocusedByWorkspace) {
        next[key] = root.lastFocusedByWorkspace[key]
      }
      next[workspace.id] = toplevel
      root.lastFocusedByWorkspace = next
    }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  readonly property int maxChars: Number(root.setting("maxChars", 15))

  function trimmedTitle(title) {
    if (title.length <= root.maxChars) return title
    return title.substring(0, root.maxChars) + "\u2026"
  }

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: root.barSize

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      RowLayout {
        id: chip
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property var toplevels: workspace ? workspace.toplevels.values : []
        readonly property var lastEntry: root.lastFocusedByWorkspace[modelData]
        readonly property string lastTitle: lastEntry ? lastEntry.title : ""
        readonly property bool lastValid: lastTitle !== "" && root.containsAddress(toplevels, lastEntry ? lastEntry.address : "")
        readonly property string windowTitle: lastValid ? lastTitle : (toplevels.length > 0 ? root.titleOf(toplevels[0]) : "")
        readonly property bool occupied: toplevels.length > 0
        readonly property bool focused: workspace !== null && workspace.focused

        spacing: Style.space(2)
        visible: chip.occupied || chip.focused

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.focusWorkspace(modelData)
          onEntered: if (root.bar && chip.windowTitle !== "") root.bar.showTooltip(chip, chip.windowTitle)
          onExited: if (root.bar) root.bar.hideTooltip(chip)
        }

        WidgetButton {
          id: numberButton
          bar: root.bar
          text: modelData === 10 ? "0" : String(modelData)
          active: chip.focused
          dimmed: !chip.focused
          horizontalMargin: 6
          verticalPadding: 6
          fixedWidth: root.vertical ? root.barSize : Style.space(20)
          fixedHeight: root.barSize
          interactive: false
        }

        Text {
          Layout.alignment: Qt.AlignVCenter
          Layout.maximumWidth: root.maxChars * 9
          visible: !root.vertical && chip.windowTitle !== ""
          text: root.trimmedTitle(chip.windowTitle)
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
          opacity: chip.focused ? 1 : 0.6
        }
      }
    }
  }
}
