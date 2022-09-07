# NFDI4IngHPCWorkflows
Within the NFDI4Ing project strategies to publish research data (which includes software and workflows) in a Findable, Accessible, Interoperable and Reusable (FAIR) manner are being developed. For HPC simulations one challenge is the often unique software stack. In this repository, we would like to investigate how (docker, apptainer) containers can be build in order to improve the FAIRness of workflows in the HPC context.

## Reproducible science in an HPC environment
To achieve reproducibility of scientific workflows (computational research) besides *automation* and *scalability*, *portability* plays an important role.
A workflow needs to be portable in the sense that all software dependencies can be automatically installed, i.e. the compute environment can be re-instantiated automatically. 
Existing workflow management systems support the deployment of the software stack by integration of container technology (docker, apptainer) or platform independent package management systems (conda).
However, (based on our current experience) several limitations to the use of such technology (docker, apptainer, conda) on a traditional HPC cluster exist:

	+ the HPC user is only allowed to build applications to be run from source,
	+ without access to the internet installing isolated conda environments or downloading container images is not possible,
	+ use of docker in HPC environments is usually discouraged due to access rights (security concerns),
	+ successfully using container technology as an MPI-distributed application seems to be a technical challenge.

Regarding the latter point, great care must be taken to build a container that is compatible (e.g. MPI implementation, drivers, ...) with the host system.
Therefore, currently a sufficient solution to enable reproducible computational research when using HPC resources does not exist.

### Wish list
With no access to the internet, the best option might be to pursue a containerized (multi-stage build) solution.
First, one would need to define a base layer, such that the container is compatible with the host system.
This may be provided by the systems administrators, since the base layer is specific to the host system.
The user is then able to build his own application (on a local machine) on top of the base layer, possibly by using conda to install software dependencies in the container.
As part of the workflow, the container image then needs to be transferred to the HPC system prior to the execution of the application.
