(use-modules (gnu) (slurm) (ice-9 binary-ports))

(use-service-modules networking ssh)
(use-package-modules ssh virtualization networking mpi)


(operating-system
  (host-name "node-a")
  (timezone "Europe/Berlin")
  (locale "en_US.utf8")

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)))

  (file-systems %base-file-systems)

  (hosts-file
   (plain-file "hosts.conf" "
192.168.0.1 controller
192.168.0.2 node-a
"))

  (users
   (cons
    (user-account
     (name "user")
     (group "users")
     (supplementary-groups '("wheel")))
    %base-user-accounts))

  (sudoers-file
   (plain-file "sudoers" "%wheel ALL=(ALL:ALL) NOPASSWD: ALL"))

  (services
   (append
    (list
     (service static-networking-service-type
              (list (static-networking
                     (addresses
                      (list (network-address
                             (device "ens6") (value "192.168.0.2/24")))))))
     (service openssh-service-type
              (openssh-configuration (openssh openssh-sans-x)))
     (service munge-service-type
              (munge-configuration
               (key (call-with-input-file "munge.key" get-bytevector-all))))
     (service slurmd-service-type
              (slurmd-configuration (conf-server "controller"))))
    %base-services))

  (packages (cons* socat bubblewrap openmpi %base-packages)))
