# MRI_scan_transfer
 Code to automate transfer of MRI data via the Douglas Neuroinformatics Platform (DNP)

## Installation
Download the repository to your local machine:
```
git clone https://github.com/katielavigne/MRI_scan_transfer.git
```
Modify the group and study to refer to your lab group and study name rather than the lepage group and LAM study. For example, if your group name is abcdef and your study is GHI:
```
sed -i 's/lepage/abcdef/g' *.sh
sed -i 's/LAM/GHI/g' *.sh
```
Copy scripts to your group/study directory on the Douglas Neuroinformatics Platform (modify the first two lines to refer to your PI's username (e.g., lepage, chamal, beaser, etc} and the study directory you created):
```
scp -r MRI_scan_transfer/*.sh username@cicws05:/data/abcdef/GHI/
```
> Off-site access is possible but requires DNP authorization.

Follow the documentation (https://github.com/katielavigne/documentation/wiki/MRI-scan-transfer) to transfer and convert scans and create links for MRI processing.
