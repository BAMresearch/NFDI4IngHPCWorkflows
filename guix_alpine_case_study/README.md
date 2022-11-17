# SLURM + MPI + Container guest launch case-study

This is a proof of concept hack which implements proxy access to a hosting SLURM
environment running on `guix` and guest MPI workload running in `alpine`.

See the [proof of concept case-study](poc.org) for more details.

## Execute case-study

> Note: The following write up is from memory and has not yet been thoroughly
> tested!

The files [controller.scm](controller.scm), [node-a.scm](node-a.scm) and
[node-b.scm](node-b.scm) contain `guix` system definitions for small 2 node
SLURM cluster. [munge.key](munge.key) and [ssh.key](ssh.key) are support files
used in these definitions.

As can be seen from [run.sh](run.sh) a subdirectory `alpine` is exposed into the
VM. This directory is expected to contain a `rootfs` from Alpine Linux, for
example this
[one](https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.3-x86_64.tar.gz).

The Alpine system needs to be manually modified, perhaps using
[bubblewrap](https://github.com/containers/bubblewrap)

- Install OpenMPI with `apk add openmpi`, for example with this command:

  ```
  bwrap --bind rootfs / --proc /proc --dev /dev --ro-bind /etc/resolv.conf /etc/resolv.conf -- /sbin/apk add openmpi
  ```

- The [srun](srun) shim needs to be copied into `/usr/bin` of the `rootfs`.

On a system with `guix` available, the [run.sh](run.sh) script will build the
SLURM VM images and spawn those as well.

Once the VMs have booted up, SSH can be used to connect to the controller node
using this command:

```
ssh -o NoHostAuthenticationForLocalhost=yes -i ssh.key ssh://user@localhost:2222
```

Inside each node, the `alpine` directory should be mounted in `/mnt`, so that
the [case-study](poc.org) can be followed.