(use-modules (gnu) (slurm) (ice-9 binary-ports))

(use-service-modules networking ssh)
(use-package-modules ssh virtualization networking mpi)

(operating-system
  (host-name "controller")
  (timezone "Europe/Berlin")
  (locale "en_US.utf8")

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)))

  (file-systems %base-file-systems)

  (hosts-file
   (plain-file "hosts.conf" "
192.168.0.1 controller
192.168.0.2 node-a
192.168.0.3 node-b
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
                             (device "ens6") (value "10.0.2.15/24"))))
                     (routes
                      (list (network-route (destination "default")
                                           (gateway "10.0.2.2"))))
                     (name-servers (list "10.0.2.3")))))
     (service static-networking-service-type
              (list (static-networking
                     (provision '(slurm-network))
                     (addresses
                      (list (network-address
                             (device "ens7") (value "192.168.0.1/24")))))))
     (service openssh-service-type
              (openssh-configuration
               (openssh openssh-sans-x)
               (authorized-keys
                `(("user" ,(local-file "ssh.key.pub"))))))
     (service munge-service-type
              (munge-configuration
               (key (call-with-input-file "munge.key" get-bytevector-all))))
     (service slurmctld-service-type
              (slurm-configuration (host "controller"))))
    %base-services))

  (packages (cons* socat bubblewrap openmpi %base-packages)))
