#!/bin/bash
# TSO500Reporter DNANexus app

set -exo pipefail

main() {

    # A: DOWNLOAD INPUTS
    echo "Fetching inputs..."

    dx-download-all-inputs --parallel



    # B: INSTALL PACKAGES
    ## Install python3
    ### Note: app entrypoint (i.e. starting directory)
    ###       will be "resources/home/dnanexus",
    ###       and "~" resolves to "/home/dnanexus"
    echo "Installing Python3..."
    tar -xvzf Python-3.10.0.tar.xz
    cd Python-3.*
    ./configure
    make install
    cd /home/dnanexus

    ## Install python packages
    echo "Installing Python packages..."

    ### 1. Install wheel
    pip3 install packages/wheel/wheel-0.37.0-py2.py3-none-any.whl

    ### 2. Install TSO500Reporter dependencies
    pip3 install packages/*.whl

    ### 3. Install TSO500Reporter
    pip3 install packages/tso500reporter/*.whl



    # C: GENERATE REPORT
    echo "Running app..."
    time python3 -m tso500reporter --variant-data *CombinedVariantOutput.tsv --samplesheet *.csv --output $output --pdf



    # D: UPLOAD RESULT TO DNANEXUS
    echo "Completed. Uploading files..."

    ## Fetch output report files
    html_report=$(find . report.html)
    pdf_report=$(find . report.pdf)

    ## Upload files to DNANexus
    html_report_id=$(dx upload $html_report --brief)
    pdf_report_id=$(dx upload $pdf_report --brief)

    ## Add workflow-output tag from outputSpec to files
    dx-jobutil-add-output report_html "$html_report_id" --class=file
    dx-jobutil-add-output report_pdf "$pdf_report_id" --class=file
}
