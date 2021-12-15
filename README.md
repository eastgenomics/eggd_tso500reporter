# eggd\_tso500reporter (DNANexus Platform App)

## What does this app do?

Generate a report containing plots and tables of Microsatellite Instability (MSI) and Tumour Mutational Burden (TMB) statistics from a TSO500 Local App job.

## What are the typical use cases for this app?

The app is intended to be a component of the Helios solid-cancer bioinformatics pipeline, which uses the TSO500 Local App as a basis. However, it can be executed as a standalone app.

## What data are required for this app to run?

#### Inputs:

- TSO500 SampleSheet.csv
- Array of TSO500 CombinedVariantOutput.tsv files

#### Example:

```
dx run app-eggd_tso500reporter -isamplesheet=${SAMPLESHEET_FILE_ID} -icombined_variant_output_files=${COMBINED_VARIANT_OUTPUT_FILE_1_ID} -icombined_variant_output_files=${CVO_FILE_2_ID} [...]
```

## What does this app output?

An HTML report of TMB and MSI plots and data.

#### This app was made by EMEE GLH
