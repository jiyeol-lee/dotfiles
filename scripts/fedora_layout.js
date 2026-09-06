// retrieve: qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.dumpCurrentLayoutJS
// apply: qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat xxx.js)"

var plasma = getApiVersion(1);

// Clear all existing panels
var allPanels = panels();
for (var i = 0; i < allPanels.length; ++i) {
  allPanels[i].remove();
}

// Clear all existing desktop widgets
var allDesktops = desktops();
for (var j = 0; j < allDesktops.length; ++j) {
  var widgets = allDesktops[j].widgets();
  for (var k = 0; k < widgets.length; ++k) {
    widgets[k].remove();
  }
}

var layout = {
  desktops: [
    {
      applets: [
        {
          config: {},
          "geometry.height": 20,
          "geometry.width": 25,
          "geometry.x": 1,
          "geometry.y": 1,
          plugin: "org.kde.plasma.calendar",
          title: "Calendar",
        },
      ],
      config: {
        "/": {
          "ItemGeometries-1694x1129": "Applet-259:848,560,416,288,0;",
          ItemGeometriesHorizontal: "Applet-259:848,560,416,288,0;",
          formfactor: "0",
          immutability: "1",
          lastScreen: "0",
          wallpaperplugin: "org.kde.image",
        },
      },
      wallpaperPlugin: "org.kde.image",
    },
  ],
  panels: [
    {
      alignment: "center",
      applets: [
        {
          config: {},
          plugin: "org.kde.plasma.panelspacer",
        },
        {
          config: {
            "/": {
              popupHeight: "217",
              popupWidth: "216",
            },
          },
          plugin: "org.kde.plasma.cameraindicator",
        },
        {
          config: {
            "/": {
              CurrentPreset: "org.kde.plasma.systemmonitor",
              popupHeight: "400",
              popupWidth: "560",
            },
            "/Appearance": {
              chartFace: "org.kde.ksysguard.piechart",
              title: "Total CPU Use",
            },
            "/SensorColors": {
              "cpu/all/usage": "61,174,233",
            },
            "/Sensors": {
              highPrioritySensorIds: '["cpu/all/usage"]',
              lowPrioritySensorIds: '["cpu/all/cpuCount","cpu/all/coreCount"]',
              totalSensors: '["cpu/all/usage"]',
            },
          },
          plugin: "org.kde.plasma.systemmonitor.cpu",
        },
        {
          config: {
            "/": {
              CurrentPreset: "org.kde.plasma.systemmonitor",
              popupHeight: "235",
              popupWidth: "238",
            },
            "/Appearance": {
              chartFace: "org.kde.ksysguard.piechart",
              title: "Memory Usage",
            },
            "/ConfigDialog": {
              DialogHeight: "630",
              DialogWidth: "810",
            },
            "/SensorColors": {
              "memory/physical/used": "61,174,233",
            },
            "/Sensors": {
              highPrioritySensorIds: '["memory/physical/used"]',
              lowPrioritySensorIds: '["memory/physical/total"]',
              totalSensors: '["memory/physical/usedPercent"]',
            },
          },
          plugin: "org.kde.plasma.systemmonitor.memory",
        },
        {
          config: {
            "/": {
              popupHeight: "213",
              popupWidth: "360",
            },
            "/General": {
              showPercentage: "true",
            },
          },
          plugin: "org.kde.plasma.battery",
        },
        {
          config: {
            "/": {
              popupHeight: "451",
              popupWidth: "560",
            },
            "/Appearance": {
              autoFontAndSize: "false",
              dateDisplayFormat: "BesideTime",
              dateFormat: "isoDate",
              fontFamily: "Noto Sans",
              fontSize: "6",
              fontStyleName: "Regular",
              fontWeight: "400",
              showDate: "false",
            },
            "/ConfigDialog": {
              DialogHeight: "630",
              DialogWidth: "810",
            },
          },
          plugin: "org.kde.plasma.digitalclock",
        },
      ],
      config: {
        "/": {
          formfactor: "2",
          immutability: "1",
          lastScreen: "0",
          wallpaperplugin: "org.kde.image",
        },
      },
      height: 2.4444444444444446,
      hiding: "normal",
      lengthMode: "fill",
      location: "top",
      maximumLength: 94.11111111111111,
      minimumLength: 94.11111111111111,
      offset: 0,
      opacity: "adaptive",
    },
  ],
  serializationFormatVersion: "1",
};

plasma.loadSerializedLayout(layout);
