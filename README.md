# mutation-signature-nf

A pipeline to discover mutation signature. Can take 


## Usgae 

```bash
nextflow run main.nf -input testdata/input_mix_vcf_origin.tsv
```

## Input

A TSV file with two columns 

```
sample_1    path_to_vcf1
sample_2    path_to_vcf2
```

Currently supported VCF files - 

* manta sv
* strelka snv