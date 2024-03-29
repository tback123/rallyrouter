import * as React from 'react';
import * as turf from '@turf/turf'
import Map, { Marker, NavigationControl, Source, Layer } from 'react-map-gl';
import Pin from './Pin.jsx';
// import * as MapMatching from '@mapbox/mapbox-sdk/services/map-matching'

import { Grid, List, ListItem, ListItemButton, ListItemText, Button, Snackbar, Alert } from '@mui/material';
import ClearIcon from '@mui/icons-material/Clear';

const MAPBOX_TOKEN = import.meta.env.VITE_MAPBOX_TOKEN;

const syd_long = 151.209900;
const syd_lat = -33.865143;

const routeStyle = {
    id: "lineLayer",
    type: "line",
    source: "my-data",
    layout: {
        "line-join": "round",
        "line-cap": "round"
    },
    paint: {
        "line-color": "rgba(3, 170, 238, 0.5)",
        "line-width": 10,
    },
};

function App() {

    const [selectedMarker, setSelectedMarker] = React.useState(null)
    const [markerJson, setMarkerJson] = React.useState(null);
    const [route, setRoute] = React.useState(null);

    const defaultSnack = {
        "show": true,
        "message": "Default Message",
        "varient": 'info'
    }

    // const mbxClient = require('@mapbox/mapbox-sdk');
    // const mbxMapMatching = require('@mapbox/mapbox-sdk/services/map-matching');
    // const baseClient = mbxClient({ accessToken: MAPBOX_TOKEN });
    // const matchingService = mbxMapMatching(baseClient);


    const [snack, setSnack] = React.useState(defaultSnack);

    const geolocateControlRef = React.useCallback((ref) => {
        if (ref) {
            // Activate as soon as the control is loaded
            ref.trigger();
        }
    }, []);

    function showErrors(error) {

    }

    function getRoute() {
        const coordinates = turf.coordAll(markerJson).join(";");
        const profile = "mapbox/driving/";

        const req_str = new URL("https://api.mapbox.com/matching/v5/");
        req_str.pathname = req_str.pathname.concat(profile);
        req_str.pathname = req_str.pathname.concat(coordinates);
        req_str.searchParams.append("geometries", "geojson");
        req_str.searchParams.append("steps", "true");
        req_str.searchParams.append("overview", "full");
        req_str.searchParams.append("access_token", MAPBOX_TOKEN);

        console.log(req_str.toString());

        fetch(req_str.toString())
            .then(response => response.json())
            .then(result => {
                setSnack({ varient: "success", show: true, message: "Got Route!" })
                setRoute(result.matchings[0].geometry);
                console.log(result);
            })
            .catch(res => {
                setSnack({ varient: "error", show: true, message: "Error Getting Route!" })
                console.log(res);
            });
    }

    function onMapClick(e) {
        setRoute(null);
        setMarkerJson(mJ => {
            // Check if this is the first marker to be added
            if (mJ) {
                return turf.featureCollection([...mJ.features, turf.point([e.lngLat.lng, e.lngLat.lat])]);
            } else {
                return turf.featureCollection([turf.point([e.lngLat.lng, e.lngLat.lat])]);
            }

        });
    }

    function onMarkerDragEnd(e, i) {
        setRoute(null);
        setMarkerJson(mJ => {
            mJ.features[i].geometry.coordinates[0] = e.lngLat.lng;
            mJ.features[i].geometry.coordinates[1] = e.lngLat.lat;
            return mJ;
        })
    }

    function onRemoveMarker(i) {
        setRoute(null);
        setMarkerJson(mJ => {

            // shallow copy the item so react will actuall update
            // Otherwise only a nexted object will change and react won't re-render
            let newMJ = { ...mJ };

            let newMJFeatures = mJ.features.filter((feat) => {

                // Only allow markers which are not the one which was clicked
                return (feat.geometry.coordinates[0] != mJ.features[i].geometry.coordinates[0]) &&
                    (feat.geometry.coordinates[1] != mJ.features[i].geometry.coordinates[1])
            })

            newMJ.features = newMJFeatures;

            if (newMJFeatures.length === 0) {
                return null;
            }

            return newMJ;
        })

        // Unselect if we just deleted the selected marker
        if (selectedMarker === i) {
            setSelectedMarker(null);
        }

    }

    function onSelectMarkerItem(i) {
        if (selectedMarker === i) {
            setSelectedMarker(null)
        } else {
            setSelectedMarker(i);
        }
    }

    function removeAllMarkers() {
        setRoute(null);
        setMarkerJson(null);
    }

    function handleCloseSnack(event, reason) {
        if (reason === 'clickaway') {
            return;
        }

        setSnack({ ...snack, show: false });
    };

    return <>
        <Snackbar open={snack.show} autoHideDuration={2000} onClose={handleCloseSnack}>
            <Alert severity={snack.varient}>{snack.message}</Alert>
        </Snackbar>
        <Grid container direction={'row'} >
            <Grid item xs={10}>
                <Map
                    mapLib={import('mapbox-gl')}
                    initialViewState={{
                        longitude: syd_long,
                        latitude: syd_lat,
                        zoom: 13
                    }}
                    style={{ height: '100vh' }}
                    mapboxAccessToken={MAPBOX_TOKEN}
                    mapStyle="mapbox://styles/mapbox/streets-v12"
                    onClick={e => { onMapClick(e) }}
                >

                    {/* <GeolocateControl ref={geolocateControlRef} trackUserLocation='true' /> */}

                    <NavigationControl />

                    {markerJson && // This cheks if markerJson is not null
                        markerJson.features.map((marker, i) => {
                            return (
                                <Marker
                                    key={i}
                                    longitude={marker.geometry.coordinates[0]}
                                    latitude={marker.geometry.coordinates[1]}
                                    anchor="bottom"
                                    draggable
                                    onDragEnd={(e) => { onMarkerDragEnd(e, i) }}
                                >
                                    <Pin selected={selectedMarker === i ? true : false} />
                                </Marker>
                            )
                        })
                    }
                    {route &&
                        <Source id='route' type='geojson' data={route}>
                            <Layer {...routeStyle} />
                        </Source>
                    }

                </Map>
            </Grid>
            <Grid item xs={2} >
                <List>
                    {markerJson &&
                        markerJson.features.map((marker, i) => {
                            return (
                                <ListItem key={i} disablePadding >
                                    <ListItemButton
                                        onClick={() => onSelectMarkerItem(i)}
                                        sx={selectedMarker === i ? { backgroundColor: 'darkgrey' } : { backgroundColor: 'lightgrey' }}
                                    >
                                        <Button onClick={() => onRemoveMarker(i)} >
                                            <ClearIcon />
                                        </Button>
                                        <ListItemText>
                                            <p>{i}</p>
                                            {/* <p>Long: {marker.geometry.coordinates[0]}</p> */}
                                            {/* <p>Lat: {marker.geometry.coordinates[1]}</p> */}
                                        </ListItemText>
                                    </ListItemButton>
                                </ListItem>
                            )
                        })}
                </List>

                <Button onClick={getRoute}>
                    <p>Get Route</p>
                </Button>
                <Button onClick={removeAllMarkers}>
                    <p>Clear Marker</p>
                </Button>
            </Grid>
        </Grid>
    </>
}

export default App;