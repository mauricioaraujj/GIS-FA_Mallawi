# High-resolution Spatial Allocation of Soybean Genotypes Using Enviromics

[![R](https://img.shields.io/badge/R-%3E%3D%204.2-blue)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-research%20code-orange)

Spatially explicit cultivar recommendation in Malawi by integrating **Factor Analytic (FA) mixed models** + **FAST** with **high-resolution environmental features** (enviromics) and **PLS/RF-based spatial prediction**.

---

## Authors

**Mauricio S. Araújo¹**, **Gabriel M. Blasques²**, **Erica P. Leles³**, **Michelle F. Santos³**, **Peter Goldsmith³**, **Godfree Chigeza³**, **Brian W. Diers³**, **José B. Pinheiro¹**

### Affiliations
1. Genetics Diversity and Breeding Laboratory, Department of Genetics, University of São Paulo (USP), Piracicaba, SP, Brazil  
2. Agroenergy Laboratory, Department of Agronomy, Federal University of Viçosa (UFV), Viçosa, MG, Brazil  
3. USAID Feed the Future Soybean Innovation Lab, University of Illinois Urbana–Champaign (UIUC), IL, USA

---

## Abstract (main results)

The integration of environmental data into predictive models has become a central component of modern plant breeding strategies. Coupling these data with robust statistical frameworks enables the selection and recommendation of genotypes with broad and specific adaptation across the target population of environments.  
Here, we identified soybean genotypes with high performance and stability under contrasting conditions and predicted genotypic performance in untested environments across Malawi. We analyzed grain yield from **153 genotypes** evaluated from **2017 to 2024/25** across **53 environments**. Genotype selection was performed using **FAST**, while prediction in untested environments integrated **FA mixed models** with high-resolution environmental features through **PLS regression**. Spatial interpolation based on **Random Forest** improved environmental characterization and optimized spatial prediction.

**Key findings**
- **Top genotype for broad adaptation:** `SCSENTINEL` showed consistently high performance and stability across environments.  
- **Which-won-where winners (spatial prediction):** `SCSENTINEL`, `SC EXPT1`, `TGx20029FM`, `TGx20145GM`, `TGx201424FM`, `TGx203392GZ`, `TGx201421FM`, `TGx200124FM`, `DARS CHITEDZE4`.  
- **Predicted grain yield range:** **482–4713 kg ha⁻¹**, showing clear patterns of general vs. specific adaptation.  
- **Regional contrast:** pairwise comparisons indicated contrasting adaptation between **Northern vs. Southern Malawi**.

---

## Results (maps)

### Mega-environments / Which-won-where (winners by zone)

> Figure: Spatial zones and genotype winners inferred from FA + enviromics prediction.

![Which-won-where zones](outputs/zones.png)

---

## Repository layout

- `data/` – raw and processed trial datasets  
- `mis/raster/` – environmental rasters / covariate layers  
- `scripts/` – reproducible pipeline (preprocess → FA/FAST → prediction → maps)  
- `outputs/` – figures, maps, and derived artifacts

---

## Reproducibility

### Requirements
- R (>= 4.2)
- Recommended: `renv` for dependency locking

### Quick start
```bash
# clone
git clone <YOUR_REPO_URL>
cd GIS-FA_Malawi
