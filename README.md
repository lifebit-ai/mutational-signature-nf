# mutation-signature-nf

A pipeline to do mutation signature analysis using [signature.tools.lib](https://github.com/Nik-Zainal-Group/signature.tools.lib). This can take a [list of VCF files as input](#input) and process them individually.

Steps - 
1. Detect the VCF files coming from a perticlar tool ([currently supported ones listed below](#currently-supported-vcf-file-from-tools))
2. Pre-processing and filtration of VCF files based on from which tools they coming from. This also standardise the vcf files going into downstream prcoessing.
3. Runs the signature-fit function based on organ-specific signatures.

## Usgae 

A basic command to run this pipeline

```bash
nextflow run main.nf --input testdata/input_mix_vcf_origin.tsv --organ "Colorectal" -with-docker
```

Take a look at [testdata/input_mix_vcf_origin.tsv](testdata/input_mix_vcf_origin.tsv)

stdout after running the above command - 

```bash
N E X T F L O W  ~  version 20.01.0
Launching `main.nf` [exotic_northcutt] - revision: fb872d5257
Launch dir        : /home/ec2-user/mutational-signature-nf
Working dir       : /home/ec2-user/mutational-signature-nf/work
Script dir        : /home/ec2-user/mutational-signature-nf
User              : ec2-user
Input             : testdata/input_mix_vcf_origin.tsv
Output dir        : results
organ             : Colorectal
bootstrap         : true
----------------------------------------------------
executor >  local (7)
[2f/5069b7] process > obtain_pipeline_metadata [100%] 1 of 1 ✔
[82/25f847] process > detect_vcf_origin_tool   [100%] 2 of 2 ✔
[6e/d3018c] process > prepare_vcf              [100%] 2 of 2 ✔
[6f/c71c15] process > signature_fit            [100%] 2 of 2 ✔
Completed at: 05-Apr-2022 12:45:49
Duration    : 1m 6s
CPU hours   : (a few seconds)
Succeeded   : 7
```

## Parameters

| param | default | description | 
|---|---|---|
| `input` | `null` | A TSV file with samples to be analysed. More details [here](#input) |
| `organ` | `"Breast"` | Which organ-specific signatures will be used in analysis. Complete list can be found [here](https://github.com/Nik-Zainal-Group/signature.tools.lib.dev/blob/dev/scripts/signatureFit#L76-L86) |
| `bootstrap` | `true` | Request signature fit with bootstrap |
| `genome_version` | `hg38` | Genome version to use, Options - `hg19` or `hg38` |
| `signaturefit_options` | `null` | Additional signaturefit options as a string |
| `preparedata_options` | `null` | Additional preparedata options as a string |

### Input

A TSV file with two columns with headers

| sample_name | vcf_file_path |
|---|---|

```
sample_name    vcf_file_path
sample_1    path_to_vcf1
sample_2    path_to_vcf2
```

### Currently supported VCF file from tools

* manta
* strelka

### Supported organs 

For `-O, --organ=ORGAN` option possible values - 

If SIGVERSION is COSMICv2 or COSMICv3.2, then a selection of signatures found in the given organ will be used. Available organs depend on the selected SIGVERSION. For RefSigv1 or RefSigv2 - 

1. Biliary
2. Bladder
3. Bone_SoftTissue
4. Breast
5. Cervix (v1 only)
6. CNS
7. Colorectal
8. Esophagus
9. Head_neck
10. Kidney
11. Liver
12. Lung
13. Lymphoid
14. NET (v2 only)
15. Oral_Oropharyngeal (v2 only)
16. Ovary
17. Pancreas
18. Prostate
19. Skin
20. Stomach
21. Uterus

Ref - From [helpmenu](https://github.com/Nik-Zainal-Group/signature.tools.lib.dev/blob/676b1e5e44aab05d788fee53b4113034d24f15f9/scripts/signatureFit#L76-L86)
