set -e

CONTROLLER=$(guix system vm -L . --expose=alpine=/mnt controller.scm)
NODE_A=$(guix system vm --expose=alpine=/mnt -L . node-a.scm)
NODE_B=$(guix system vm --expose=alpine=/mnt -L . node-b.scm)

$CONTROLLER \
    -device driver=e1000,netdev=ssh -netdev user,id=ssh,hostfwd=::2222-:22 \
    -device driver=e1000,netdev=net,mac=52:54:00:00:00:01 \
    -netdev socket,id=net,mcast=230.0.0.1:1234 -nographic &

$NODE_A \
    -device driver=e1000,netdev=net,mac=52:54:00:00:00:02 \
    -netdev socket,id=net,mcast=230.0.0.1:1234 -nographic &

$NODE_B \
    -device driver=e1000,netdev=net,mac=52:54:00:00:00:03 \
    -netdev socket,id=net,mcast=230.0.0.1:1234 -nographic &

wait $(jobs -p)
