# DICOMS to BIDS format

**1.** Download or `git clone` this directory  
```bash
git clone https://github.com/rcruces/MRI_analytic_tools.git DICOM_2_BIDS
```
**2.** Define on your environment the GITHUB repository PATH as `gitpath`:
```bash
export gitpath=<YOUR PATH to the top GITHUB repository>
```
**3.** Make executable these scrip_test
```bash
chmod aug+xX ${gitpath}/MRI_analytic_tools/DICOM_2_BIDS/*
```
**4.** Add this directory to your PATH
```bash
export PATH=$PATH:${gitpath}/MRI_analytic_tools/DICOM_2_BIDS
```
**5.** These scripts REQUIRE `dcm2niix` to work:  
> https://github.com/rordenlab/dcm2niix

## `dcm2bids`

## `unam2BIDS`
