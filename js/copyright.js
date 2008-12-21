var modestMaps = {
    copyrightCallback: function(holdersHTML)
    {
        alert('Copyright holders for this map: '+holdersHTML);
    },
    
    copyright:
        function(provider, cenLat, cenLon, minLat, minLon, maxLat, maxLon, zoom)
        {
            switch(provider) {
                case 'BLUE_MARBLE':
                    this.copyrightCallback('Image courtesy of NASA');
                    break;
        
                case 'OPEN_STREET_MAP':
                    this.copyrightCallback('Image courtesy of OpenStreetMap');
                    break;
        
                case 'MICROSOFT_ROAD':
                    this.microsoft.copyright('road', minLat, minLon, maxLat, maxLon, zoom);
                    break;
        
                case 'MICROSOFT_AERIAL':
                    this.microsoft.copyright('aerial', minLat, minLon, maxLat, maxLon, zoom);
                    break;
        
                case 'MICROSOFT_HYBRID':
                    this.microsoft.copyright(undefined, minLat, minLon, maxLat, maxLon, zoom);
                    break;
            } 
        }
    },

    microsoft: {
        holders:
            {'microsoft':   '&copy; 2006 Microsoft Corporation',
             'navteq':      '&copy; 2006 NAVTEQ',
             'and':         '&copy; AND',
             'mds':         '&copy; 2006 MapData Sciences Pty Ltd',
             'zenrin':      '&copy; 2006 Zenrin',
             'nasa':        'Image courtesy of NASA',
             'harris':      '&copy; Harris Corp, Earthstar Geographics LLC',
             'usgs':        'Image courtesy of USGS',
             'earthdata':   '&copy; EarthData',
             'getmap':      '&copy; Getmapping plc',
             'geoeye':      '&copy; 2006 GeoEye',
             'pasco':       '&copy; 2005 Pasco'},
    
        // tract: [kind, holder, min zoom, max zoom, min lat, min lon, max lat, max lon]
        tracts:
            [['road', 'microsoft', 1, 20, -90, -180, 90, 180],
             ['road', 'navteq', 1, 9, -90, -180, 90, 180],
             ['road', 'navteq', 10, 19, 16, -180, 90, -50],
             ['road', 'navteq', 10, 19, 27, -32, 40, -13],
             ['road', 'navteq', 10, 19, 35, -11, 72, 20],
             ['road', 'navteq', 10, 19, 21, 20, 72, 32],
             ['road', 'navteq', 10, 17, 21.92, 113.14, 22.79, 114.52],
             ['road', 'navteq', 10, 17, 21.73, 119.7, 25.65, 122.39],
             ['road', 'navteq', 10, 17, 0, 98.7, 8, 120.17],
             ['road', 'navteq', 10, 17, 0.86, 103.2, 1.92, 104.45],
             ['road', 'and', 10, 19, -90, -180, 90, 180],
             ['road', 'mds', 5, 17, -45, 111, -9, 156],
             ['road', 'mds', 5, 17, -49.7, 164.42, -30.82, 180],
             ['road', 'zenrin', 4, 18, 23.5, 122.5, 46.65, 151.66],
             ['road', 'microsoft', 1, 20, -90, -180, 90, 180],
             ['aerial', 'nasa', 1, 8, -90, -180, 90, 180],
             ['aerial', 'harris', 9, 13, -90, -180, 90, 180],
             ['aerial', 'usgs', 14, 19, 17.99, -150.11, 61.39, -65.57],
             ['aerial', 'earthdata', 14, 19, 21.25, -158.3, 21.72, -157.64],
             ['aerial', 'earthdata', 14, 19, 39.99, -80.53, 40.87, -79.43],
             ['aerial', 'earthdata', 14, 19, 34.86, -90.27, 35.39, -89.6],
             ['aerial', 'earthdata', 14, 19, 40.6, -74.18, 41.37, -73.51],
             ['aerial', 'getmap', 14, 19, 49.94, -6.35, 58.71, 1.78],
             ['aerial', 'geoeye', 14, 17, 44.43, -63.75, 45.06, -63.45],
             ['aerial', 'geoeye', 14, 17, 45.39, -73.78, 45.66, -73.4],
             ['aerial', 'geoeye', 14, 17, 45.2, -75.92, 45.59, -75.55],
             ['aerial', 'geoeye', 14, 17, 42.95, -79.81, 44.06, -79.42],
             ['aerial', 'geoeye', 14, 17, 50.35, -114.26, 51.25, -113.82],
             ['aerial', 'geoeye', 14, 17, 48.96, -123.33, 49.54, -122.97],
             ['aerial', 'geoeye', 14, 17, -35.42, 138.32, -34.47, 139.07],
             ['aerial', 'geoeye', 14, 17, -32.64, 115.58, -32.38, 115.85],
             ['aerial', 'geoeye', 14, 17, -34.44, 150.17, -33.27, 151.49],
             ['aerial', 'geoeye', 14, 17, -28.3, 152.62, -26.94, 153.64],
             ['aerial', 'pasco', 14, 17, 23.5, 122.5, 46.65, 151.66]],
    
        copyright:
            function(kind, minLat, minLon, maxLat, maxLon, zoom)
            {
                var tracts = this.tracts;
                var holders = [];
                var matches = {};
    
                for(var i = 0; i < tracts.length; i += 1) {
                    var tract = tracts[i];
                    if((tract[0] == kind || !kind) && tract[2] <= zoom && zoom <= tract[3] && tract[4] <= maxLat && minLat <= tract[6] && tract[5] <= maxLon && minLon <= tract[7]) {
                        matches[tract[1]] = true;
                    }
                }
                
                for(var p in matches) {
                    holders.push(this.holders[p]);
                }
    
                modestMaps.copyrightCallback(holders.join(', '));
            }
    }
};

