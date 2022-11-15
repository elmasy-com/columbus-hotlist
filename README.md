# columbus-popular

This repository is used to collect commonly used, popular domains and periodically run external tools on it to keep the [Columbus Server](https://github.com/elmasy-com/columbus-server) up-to-date.

Currently used tools:
- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [Amass](https://github.com/OWASP/Amass)


## Install

The required tools are comes with this repository. See the `bin/` directory.

This script is using [columbus-cli](https://github.com/elmasy-com/columbus-cli) to interact with the Columbus Server.
To use this script, the `COLUMBUS_KEY` environment variable must set.

`run.sh` must be executed in this directory!

Multiple `run.sh` cant run parallel, becuse it creates and checks the existence of `/tmp/columbus-popular.pid`.

Depending on the size of `popular.domains`, the easiest method is to set a cronjob.

Example to run every hour:
```
0 * * * * cd /path/to/repo && bash run.sh > /path/to/log
```

If a file with name `uptimehook` exist, the script will call the content URL on every iteration.

Example content of `uptimehook` file:
```
https://example.com/uptimehook
```

## List format

- Comment is allowed with `//`
- Empty lines are ignored
- One domain per line, without any whitespace
- The list must ends with an empty line 