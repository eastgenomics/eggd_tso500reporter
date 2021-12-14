#!/bin/bash
# TSO500Reporter DNANexus app

set -exo pipefail

main() {

    # A: DOWNLOAD INPUTS
    echo "Fetching inputs..."

    dx-download-all-inputs --parallel


    # B: INSTALL DEPENDENCIES
    ## Install libffi-dev (dependency of _ctypes python module)
    apt-get install ./libffi-dev_3.3-4_amd64.deb

    ## Install python3
    ### Note: app entrypoint (i.e. starting directory)
    ###       will be "resources/home/dnanexus",
    ###       and "~" resolves to "/home/dnanexus"
    echo "Installing Python3..."
    tar xf Python-3.8.0.tar.xz
    cd Python-3.8.0
    ./configure
    make install
    cd /home/dnanexus

    ## Install python packages
    echo "Installing Python packages..."

    ### 1. Install wheel
    pip3 install packages/wheel/*.whl --no-deps --no-index

    ### 2. Upgrade pip
    pip3 install packages/pip/*.whl --no-deps --no-index

    ### 3. Install TSO500Reporter dependencies
    pip3 install packages/*.whl --no-deps --no-index

    ### 4. Install TSO500Reporter
    pip3 install packages/tso500reporter/*.whl --no-deps --no-index


    # C: GENERATE REPORT
    echo "Running app..."
    time python3 -m tso500reporter --samplesheet $(find ~/in/ -name *.csv) --variant-data $(find ~/in/ -name *CombinedVariantOutput.tsv | paste -sd' ')


    # D: UPLOAD RESULT TO DNANEXUS
    echo "Completed. Uploading files..."

    ## Fetch output report files
    HTML_REPORT=$(find . -name report.html)

    ## Rename report
    ### extract run name from a CombinedVariantOutput file
    CVO_FILES=($(find . -name *.tsv))
    RUN_NAME=$(grep "Run Name" ${CVO_FILES[1]} | sed -E "s/^[^0-9]+//" | sed -E "s/\s//g")

    ### generate report name
    REPORT_NAME="${RUN_NAME}.tmb_msi.report.html"

    ### rename report
    HTML_REPORT_DIR=$(dirname $HTML_REPORT)
    mv $HTML_REPORT ${HTML_REPORT_DIR}/${REPORT_NAME}
    HTML_REPORT=${HTML_REPORT_DIR}/${REPORT_NAME}

    ## Upload files to DNANexus
    HTML_REPORT_ID=$(dx upload $HTML_REPORT --brief)

    ## Add workflow-output tag from outputSpec to files
    dx-jobutil-add-output report_html "$HTML_REPORT_ID" --class=file
}
