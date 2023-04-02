# urbit-go
The abstract board-game Go, now on Urbit

## Installation

The app is available from [~disreb-winner-mittec/urbit-go](web+urbitgraph://~disreb-winner-mittec/urbit-go)

## Building

Begin by spinning up a fakezod

You will need to clone the urbit repository from github here: https://github.com/urbit/urbit
You will also need to clone the landscape repository from github here: https://github.com/tloncorp/landscape

For the sake of this installation, this cloned repo is referred to as 'urbit-git'

### Creating the base desk

1. In your fakezod, create the skeleton desk by running `|merge %urbit-go our %base` and `|mount %urbit-go`

2. On the unix side, navigate to your pier and delete the contents on the 'urbit-go' folder
3. Copy the contents of base-dev in urbit-git/pkg to the now-empty urbit-go folder in your fakezod
4. Copy the contents of desk-dev in landscape-git to the urbit-go folder in your fakezod
5. Create an app/ and gen/ folder

### Adding gall files

Run the install script `install.sh` to copy files from the repository to your pier's folder, or vice-versa.

Then run `|commit %urbit-go` and finally `|install our %urbit-go`

It will ask for a glob file. Navigate to http://127.0.0.1:8080/docket/upload (or wherever you host your fakezod). Then select 'urbit-go'
as the app, and upload the 'urbit-go-glob' folder in this repository. If all goes well, you'll have a working install.

**Note:** If you are not running this on a fakezod, you will need to update desk.docket-0 glob-ames to the name of your ship

## Progress

The app works, notifications coming soon(tm)

The Front-end repository is [here](https://github.com/Vrend/urbit-go-frontend), but has been built into the glob folder of this repository.

## Contributing

Contributions are accepted and encouraged! Feel free to make a pull request, but make sure to provide
an adequate explanation of what your contribution changes or adds.

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

*Copyright (C) 2023 Vrend*
