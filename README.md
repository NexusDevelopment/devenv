# devenv 
A base repository for Nexus developers.

[![Slack Status](http://slack.makerdao.com/badge.svg)](https://slack.makerdao.com)

# Setting up Docker

One day we will remove the requirement of building one's own development Docker,
but that day is not today. Run the following command from the repository's root
directory and then go have lunch:

```
docker build -t nexus_image .
```

Once the build is done, you'll want to make an instance of the Docker image.
Start by copying your `~/.ssh` directory, if you want to use your SSH keys with
Github (recommended) to `~/.ssh-docker`. If you don't want to mess with SSH keys
right now but think you might in the future, then go ahead and just run `mkdir
~/.ssh-docker` for now. Whichever you choose, you'll then run:

```
docker run -d --name nexus -v ~/.ssh-docker:/root/.ssh nexus_image
```

This creates an instance of the `nexus_image` Docker image and names it `nexus`,
mounts your `~/.ssh-docker` directory at `/root/.ssh` in the Docker image instance,
and then starts it up and forks it into the background.


To log into your Docker image instance and start coding:

```
docker exec -u dev -it nexus ssh-agent bash
```

This starts up an instance of `bash` in your Docker image instance via
`ssh-agent` (so SSH keys unlocked via `ssh-add` stay unlocked) and then connects
your terminal to it.

If you pulled the image from Docker Hub, then `dapple` will already be
installed. If you built it per the instructions above, you will need to run:

```
cd ~/devenv/dapple
npm install -g .
```

If your image instance is ever stopped (as it will be after a reboot), you can
restart it with:

```
docker start nexus
```
