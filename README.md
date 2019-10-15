# bitmovin-player-roku-samples
Sample channels for the Bitmovin Player Roku SDK

## Available Sample Channels
+ **BasicPlayback**: on channel load will display a simple selection screen of two videos. The Roku remote can be used to select a video. On selection, the video will load and the roku remote or api calls can be used for actions such as play/pause/seek. Hitting the back arrow unloads the video and returns the user to the selection screen.

+ **SideloadedThumbnailScubbingSingleImages**: After the player SDK is successfully loaded, the `setup` function will be triggered which will result in video being played. `uiExample` will be used as a custom UI for the player. The Roku remote can be used to fast forward/rewind the video which will in turn result with thumbnail image being shown at appropriate/requested time. The "OK" button can be used to resume the video playback.

+ **SideloadedThumbnailScubbingSpriteSheet**: Using `getThumbnail` API with a stream containing thumbnails in the form of sprite sheets. Inside `init` function of `PlayerExample`, task named `BackgroundRunningTask` is started.
`BackgroundRunningTask` is using the data provided by the `getThumbnail` API to store sprite sheets as well as to crop them in order to get and store thumbnail image for specific time.
`UiExample` is using the data extracted by the `BackgroundRunningTask` to show the thumbnail image.
The Roku remote can be used to fast forward/rewind the video which will in turn result with thumbnail image being shown at appropriate/requested time. The "OK" button can be used to resume the video playback.

## Running a Sample Channel
To run a sample channel, you must have a Roku running on the same network as your machine.
The Roku will need to be set in developer mode. To reach the screen to do this, hit the followings keys on the remote: *Home, Home, Home, Up, Up, Right, Left, Right, Left, Right*.
At this point, the Developer Settings view should show. Select to enable the installer and follow the instructions.

Once that is done, enter the IP for the Roku device (shown on the Developer Settings view, or under *Network > Settings > About*) into your browser and a page will show that allows for uploading and installing channels to the device.

Open the manifest file for the sample channel you want to use and add your player license key there: `bitmovin_player_license_key=LICENSE_KEY`. The player license key can be found in the [Bitmovin Dashboard](http://dashboard.bitmovin.com/) when navigating to `Player -> Licenses`.

In order for the license key to validate properly, you must add the channel ID as a domain in the [Bitmovin Dashboard](http://dashboard.bitmovin.com/). In the dashboard, under `Player > Licenses`, add `dev.roku` as a domain. This domain allows side loaded channels to run with this specific player license key. When a channel is published to the store, the domain which needs to be added to the dashboard is `CHANNEL_ID.roku`, where `CHANNEL_ID` is the ID of the submitted channel in the Roku channel store.

To upload and install a channel, zip together the contents of the channel folder (`manifest` file, `source`, `images` and `components` directories) and upload it to the Roku device. Upon install, the channel should run immediately.

The Roku debug console can be accessed using telnet:
`telnet [Roku IP address] 8085`

## Documentation And Release Notes
+ You can find the latest API documentation [here](https://bitmovin.com/docs/player/api-reference/roku/roku-sdk-api-reference-v1)
+ The release notes can be found [here](https://bitmovin.com/docs/player/releases/roku)
