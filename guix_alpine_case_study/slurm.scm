(define-module (slurm)
  #:use-module (guix records)

  #:use-module (gnu)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages parallel)
  #:use-module (gnu services shepherd)

  #:export
  (munge-configuration
   munge-service-type
   slurm-configuration
   slurmctld-service-type
   slurmd-configuration
   slurmd-service-type))


(define-record-type* <munge-configuration>
  munge-configuration make-munge-configuration
  munge-configuration?

  (munged
   munge-configuration-munged
   (default (file-append munge "/sbin/munged")))

  (key munge-configuration-key (default #f)))


(define (munge-shepherd-service config)
  "Return a <shepherd-service> for munge with CONFIG."

  (define munge-command
    #~(list #$(munge-configuration-munged config)
            "--foreground" "--key-file" "/etc/munge/munge.key"
            "--pid-file" "/var/run/munge.pid"
            "--log-file" "/var/run/munge.log"))

  (list (shepherd-service
         (documentation "Run the munge daemon.")
         (provision '(munge))
         (requirement '(user-processes))
         (start #~(make-forkexec-constructor
                   #$munge-command
                   #:pid-file "/var/run/munge.pid"))
         (stop #~(make-kill-destructor)))))


(define (munge-activation config)
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils) (ice-9 binary-ports))

        (mkdir-p "/etc/munge")
        (mkdir-p "/var/lib/munge")
        (mkdir-p "/var/run/munge")
        (call-with-output-file "/etc/munge/munge.key"
          (lambda (port) (put-bytevector
                          port #$(munge-configuration-key config))))
        (chmod "/etc/munge/munge.key" #o700))))


(define munge-service-type
  (service-type
   (name 'munge)
   (description "Run the munge daemon, @command{munge}.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             munge-shepherd-service)
          (service-extension activation-service-type
                             munge-activation)))
   (default-value (munge-configuration))))


(define-record-type* <slurm-configuration>
  slurm-configuration make-slurm-configuration
  slurm-configuration?

  (slurmctld
   slurm-configuration-slurmctld
   (default (file-append slurm "/sbin/slurmctld")))

  (cluster-name
   slurm-configuration-cluster-name
   (default "cluster"))

  (host
   slurm-configuration-host
   (default "localhost")))


(define-record-type* <slurmd-configuration>
  slurmd-configuration make-slurmd-configuration
  slurmd-configuration?

  (slurmd
   slurmd-configuration-slurmd
   (default (file-append slurm "/sbin/slurmd")))

  (conf-server
   slurmd-configuration-conf-server
   (default "localhost")))


(define %slurm.conf-template
  "ClusterName=~a

AuthType=auth/munge
JobCompType=jobcomp/filetxt
SchedulerType=sched/backfill

SlurmctldHost=~a # localhost(127.0.0.1)
SlurmctldParameters=enable_configless
SlurmctldDebug=debug

SlurmdDebug=debug

StateSaveLocation=/var/spool/slurmctld

SwitchType=switch/none
ProctrackType=proctrack/linuxproc

# Node Configurations
NodeName=DEFAULT CPUs=1 Sockets=1 CoresPerSocket=1 ThreadsPerCore=1 RealMemory=256 State=UNKNOWN
NodeName=node-a
NodeName=node-b

# Partition Configurations
PartitionName=DEFAULT MaxTime=30 MaxNodes=10 State=UP
PartitionName=debug Nodes=ALL Default=YES
")


(define %cgroup.conf-template
  "CgroupPlugin=cgroup/v1
")


(define (slurm-config-file config)
  "Return the SLURM configuration file corresponding to CONFIG."
  (computed-file
   "slurm.conf"
   #~(begin
       (use-modules (ice-9 match))
       (call-with-output-file #$output
         (lambda (port)
           (format port #$%slurm.conf-template
                   #$(slurm-configuration-cluster-name config)
                   #$(slurm-configuration-host config))
           #t)))))


(define (slurm-cgroup-config-file config)
  "Return the SLURM cgroup configuration file corresponding to CONFIG."
  (computed-file
   "cgroup.conf"
   #~(begin
       (use-modules (ice-9 match))
       (call-with-output-file #$output
         (lambda (port)
           (format port #$%cgroup.conf-template)
           #t)))))


(define (slurmctld-activation config)
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils))

        ;; Make sure /etc/ssh can be read by the 'sshd' user.
        (mkdir-p "/etc/slurm")
        (chmod "/etc/slurm" #o755)

        (mkdir-p "/var/spool/slurmctld")

        (copy-recursively #$(slurm-config-file config)
                          "/etc/slurm/slurm.conf")

        (copy-recursively #$(slurm-cgroup-config-file config)
                          "/etc/slurm/cgroup.conf"))))


(define (slurmd-activation config)
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils))

        (mkdir-p "/var/spool/slurmd"))))


(define (slurmctld-shepherd-service config)
  "Return a <shepherd-service> for slurmctld with CONFIG."

  (define slurmctld-command
    #~(list #$(slurm-configuration-slurmctld config) "-D"))

  (list (shepherd-service
         (documentation "Run the slurmctld daemon.")
         (provision '(slurmctld))
         (requirement '(user-processes munge networking))
         (start #~(make-forkexec-constructor
                   #$slurmctld-command
                   #:pid-file "/var/run/slurmctld.pid"))
         (stop #~(make-kill-destructor)))))


(define (slurmd-shepherd-service config)
  "Return a <shepherd-service> for slurmd with CONFIG."

  (define slurmd-command
    #~(list #$(slurmd-configuration-slurmd config)
            "--conf-server" #$(slurmd-configuration-conf-server config)))

  (list (shepherd-service
         (documentation "Run the slurmd daemon.")
         (provision '(slurmd))
         (requirement '(user-processes munge networking))
         (start #~(make-forkexec-constructor
                   #$slurmd-command
                   #:pid-file "/var/run/slurmd.pid"))
         (stop #~(make-kill-destructor)))))


(define slurmctld-service-type
  (service-type
   (name 'slurmctld)
   (description "Run the SLURM control daemon, @command{slurmctld}.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             slurmctld-shepherd-service)
          (service-extension activation-service-type
                             slurmctld-activation)
          (service-extension profile-service-type
                             (lambda (config) (list slurm)))))
   (default-value (slurm-configuration))))


(define slurmd-service-type
  (service-type
   (name 'slurmd)
   (description "Run the SLURM daemon, @command{slurmd}.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             slurmd-shepherd-service)
          (service-extension activation-service-type
                             slurmd-activation)))
   (default-value (slurmd-configuration))))
