### Dockerized ArchLinux Repository

#### Why ?

At work we use and love ArchLinux, we're all working on it. But something hit me, we spend a lot of time waiting for packages to download due to a slow internet connection. So, I decided to create a local ArchLinux Repository. We also love and use Docker, that's why I dockerized it. This image provides a simple way to deploy an ArchLinux Repository the easiest way possible.

#### How to use it ?

Simply run the image (bahaika/arch-repo), you can configure it with the `/etc/arch-mirror/config.yml` file inside the container. I also recommend to use volumes for :

  - `/var/mirror` (containing the mirror itself)
  - `/etc/arch-mirror` (containing the configuration of the mirror and the watchdog)

#### TL;DR

Run the repo with the default configuration :

```
docker run -d --name=archrepo -p 80:80 \
  -v ./mirror:/var/mirror \
  -v ./config:/etc/arch-mirror \
  bahaika/arch-repo
``` 
