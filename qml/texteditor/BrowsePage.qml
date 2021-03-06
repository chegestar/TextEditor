import QtQuick 1.1
import Qt.labs.folderlistmodel 1.0
import com.nokia.meego 1.0

Page {

    property variant content: content
    property alias folderPath: folderModel.folder;
    property bool saveAs: false

    property string buttonBackground: "image://theme/color"+theme.colorScheme+"-meegotouch-button-accent-background"
    property string buttonFontFamily : appDefaults.cFONT_FAMILY_BUTTON
    property int buttonFontSize : appDefaults.cFONT_SIZE_BUTTON

    signal folderChanged(string path);

    property bool refresh: false

    // When folder is changed update newFolder and header/model data
    onFolderChanged: {
        header.infoBottomText = path
        folderModel.folder = path
        newFolderChanged(path)
    }

    // Instantiate the BrowseTools component (defined in BrowseTools.qml)
    BrowseTools{
        id: browseTools
        visible: true
    }

    // Instantiate the BrowseMenu component (defined in BrowseMenu.qml)
    BrowseMenu {
        id: browseMenu
    }

    Column {
        width: parent.width
        height: parent.height

        // Button style for the page header Save As button
        ButtonStyle {
            id: buttonStyle
            textColor: "white"
            fontFamily: buttonFontFamily
            fontPixelSize: buttonFontSize
            background: buttonBackground
            pressedBackground: buttonBackground+"-pressed"
        }

        // The page header (with a Save As button if saveAs = true)
        Header {
            id: header
            singleLineHeader: false
            infoTopText: (saveAs)?qsTr("Save as"):qsTr("Open")
            infoBottomText: folderPath
            // Save As button
            Button {
                id: saveAsButton
                platformStyle: buttonStyle
                visible: saveAs
                width: 130; height: 40
                anchors { right: parent.right; rightMargin: defaultMargin
                    verticalCenter: parent.verticalCenter}
                text: qsTr("Save")
                onClicked: {
                    saveAsRequested(editPage.content,saveasfile.text);
                }
            }
        }

        // Prompt for a file name for Save As
        TextField {
            id: saveasfile
            visible: saveAs
            width:parent.width;
            placeholderText: qsTr("File to save")
            Keys.onReturnPressed: {
                saveAsRequested(editPage.content,saveasfile.text);
            }
        }

        // Folder list
        ListView {
            id: listView
            clip: true
            height: (saveAs?-saveasfile.height:0) + parent.height - header.height - appDefaults.cDEFAULT_MARGIN - browseTools.height;
            width: parent.width;

            delegate: FileDelegate {
                isDir: folderModel.isFolder(index)
            }

            // property 'folder' specifies the folder to list
            // roles 'fileName' and 'filePath' provide access to the current item
            model: FolderListModel {
                id: folderModel
                nameFilters: ["*"]
                showDirs: true
                showDotAndDotDot: false
            }
        }
    }

    // Called twice: 1) refresh=true 2) refresh=false
    // Change state from "refreshing" to "refreshed"
    onRefreshChanged: {
        state = (refresh)?"refreshing":"refreshed"
        refresh = false
    }

    state: "refreshed"
    states: [
        State {
            name: "refreshing"
            PropertyChanges {target: statusLabel; opacity: 1.0}
            PropertyChanges {target: listView; opacity: 0}
            PropertyChanges {target: folderModel; nameFilters: [""]}
        },
        State {
            name: "refreshed"
            PropertyChanges {target: folderModel; nameFilters: ["*"]}
        }
    ]

    // Status label to give some visual feedback for the "refresh" button click
    Label {
        id: statusLabel
        opacity: 0
        color:  "orange"
        font.pixelSize: 42
        text: qsTr("Refreshing")+"..."
        anchors.centerIn: parent
    }

    // Animations to give some visual feedback for the "refresh" button click
    transitions: [
        Transition {
            from: "refreshing"
            to: "refreshed"
            PropertyAnimation {
                target: statusLabel
                property: "opacity"
                to: 0
                duration: 1000
            }
            PropertyAnimation {
                target: listView
                property: "opacity"
                to: 1
                duration: 1000
            }
        }
    ]
}
