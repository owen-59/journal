# Journal Website
A journaling website like some certain more premium paid options, but without any AI features, or payment. It works on the web by storing your markdown files on your server, and storing them with front-matter (mostly) compatible with Obsidian and then hosting a website at which they are accessibly from. The website currently has no authentication, so do not expose it publicly. 

## Features
 - Images
 - Tags
 - Location data
 - Markdown editor

## Install
Clone the repository with `git`, install `pnpm` and `flutter`. In the `frontend` directory, run `flutter run -d web-server --web-port=8080 --release`, and in the `backend` directory, run `pnpm run dev`. Currently, you have to be accessing the website on the same computer as you are running it.

## Transitioning from Day One
This tool is very rough and does not support all Day One features. To run this tool, ensure you have node with typescript, and put your Journal Export in the folder root as Export-Journal/Export-Journal.json.
 - Download your Day One data as JSON.
 - Use the tool at [owen-59/dayone2journal](https://github.com/owen-59/dayone2journal).
