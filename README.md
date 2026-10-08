<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=rect&height=170&color=0:111827,100:1f2937&text=Nanda%20Siddhardha&fontColor=F9FAFB&fontSize=46&fontAlignY=40&desc=Master's%20in%20Biomedical%20Engineering&descAlignY=62" alt="Hero banner" />
</p>

<p align="center">
  <img src="https://komarev.com/ghpvc/?username=sid-6921&label=Profile%20Views&color=374151&style=flat" alt="Profile views" />
</p>

<h3 align="center">Biomedical intelligence systems for real clinical use.</h3>

## About

I am currently pursuing a Master's in Biomedical Engineering.

My work centers on biomedical signal intelligence, diagnostic modeling, and production-ready health-tech workflows. Cybersecurity was a strong undergraduate hobby and still informs my approach to reliability, privacy, and resilient deployment.

## Research Philosophy

- Build beyond prototypes: prioritize deployability from day one.
- Keep models clinically interpretable, not just statistically strong.
- Design for reliability, reproducibility, and patient-context constraints.

## Current Directions

- Biomedical signal processing for diagnostics and monitoring
- Machine learning pipelines for healthcare prediction tasks
- Embedded and VLSI-assisted sensing architectures
- Reproducible health-tech experimentation and evaluation

## Academic Trajectory

- Now: advancing biomedical ML workflows for practical clinical utility
- Next: translating validated prototypes into robust healthcare tools

## Open Source Contributions

Bugs found by reading code and comparing sibling functions, not by picking up issues off a tracker — each fix below was reproduced locally before being submitted.

<!-- OSS-STATS:START -->
**Snapshot:** 7 repos where I am a credited contributor (merged commits) plus 1 co-authored credit (not reflected in the count above -- see below) · 21 merged PRs · ~20 open PRs under review.
<!-- OSS-STATS:END -->

### Contributor repos (merged)

#### [MakazhanAlpamys/Soup](https://github.com/MakazhanAlpamys/Soup) ⭐ 8.3k — LLM fine-tuning CLI
13 merged PRs — security (SSRF predicate consolidation), training reliability (checkpoint resume, failure-boundary widening, nonce-based worker verification), and data-path correctness (format validation, stripe-root re-validation on every shard write).
- **Impact:** the SSRF fix (#625) closed a loopback/private-host bypass across the whole request path, not one call site; the stripe-recheck fix (#1663) turned a silent data-corruption window into a surfaced-and-refused failure, via a maintainer-found volume-mount-point edge case reproduced and fixed live.
- **Scope:** largest body of work here by PR count; several of the 13 are substantial test/fixture reworks.

#### [Project-MONAI/MONAI](https://github.com/Project-MONAI/MONAI) ⭐ 8.8k — medical imaging DL framework
[#8956](https://github.com/Project-MONAI/MONAI/pull/8956) merged: fixed a divide-by-zero in the pydicom affine computation for single-slice volumes.
- **Impact:** single-slice DICOM series (localizers, scouts) are routine in practice; before this fix, loading one silently crashed instead of producing a usable affine.
- A second PR ([#9134](https://github.com/Project-MONAI/MONAI/pull/9134), open) fixes `MeanIoU`'s `ignore_index` to mask voxels instead of zeroing a whole channel — it disagreed with `compute_dice()` on identical input (1.0 vs 0.667) and had shipped untested since PR #8757.

#### [alphaXiv/OpenResearch](https://github.com/alphaXiv/OpenResearch) ⭐ 6.8k — research-paper reading platform
[#351](https://github.com/alphaXiv/OpenResearch/pull/351) merged: added a full Hindi (hi) locale, +1,413/−229 across 6 files.
- **Impact:** covers UI strings end-to-end rather than a partial translation — first locale contribution of this size on the repo at the time.
- A follow-up cleanup ([#585](https://github.com/alphaXiv/OpenResearch/pull/585), open) removes a `statusColor` helper that drifted out of sync with `StatusBadge`, confirmed unused via a repo-wide grep including wildcard re-export paths.

#### [nipy/nibabel](https://github.com/nipy/nibabel) ⭐ 794 — neuroimaging I/O library
2 merged PRs: [#1553](https://github.com/nipy/nibabel/pull/1553) generalized `rescale_affine()` to non-4x4 affines (hardcoded to `affine[:3,:3]` despite being documented for arbitrary `(N,N)`); [#1562](https://github.com/nipy/nibabel/pull/1562) added shape validation to `Nifti1Header.set_sform`.
- **Impact:** #1553 fixed a function that raised on any non-square-4 input despite its own docstring promising general support — a docs/implementation contract break.
- Both found via sibling-function comparison (`rescale_affine` vs. `voxel_sizes` — one generalized to N-d, the other did not).

#### [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) ⭐ 203 — data-table/query library
2 merged PRs, both first-pass clean: [#75](https://github.com/neuralinkcorp/datarepo/pull/75) added missing `is null`/`is not null` filter support on `ParquetTable` (already present for Clickhouse and Delta); [#76](https://github.com/neuralinkcorp/datarepo/pull/76) replaced a bare dict-subscript `KeyError` with a clear error for unsupported ROAPI partition column types.
- **Impact:** #75 closed a feature gap between three backends meant to share one filter contract; #76 turned an opaque internal exception into an actionable error.
- A third PR ([#78](https://github.com/neuralinkcorp/datarepo/pull/78), open) fixes unescaped SQL interpolation in a codegen path — an injection-shaped bug in generated code.

#### [InsightSoftwareConsortium/ITK](https://github.com/InsightSoftwareConsortium/ITK) ⭐ 1.7k — medical image processing toolkit
[#6932](https://github.com/InsightSoftwareConsortium/ITK/pull/6932) merged same day as opened: `array_view_from_vnl_vector` aliased the deep-copy function instead of the documented view/no-copy function.
- **Impact:** silently broke a documented no-copy contract — callers relying on in-place mutation through the view got a disconnected copy, with no error raised.
- Two more open the same week: [#6936](https://github.com/InsightSoftwareConsortium/ITK/pull/6936) fixes a `TypeError` in `transform_from_dict` for composite (multi-)transforms; [#6937](https://github.com/InsightSoftwareConsortium/ITK/pull/6937) fixes `image_from_xarray()` assigning origin/spacing to the wrong axes on 4D images.

#### [keras-team/keras](https://github.com/keras-team/keras) ⭐ 64.4k
[#23860](https://github.com/keras-team/keras/pull/23860) merged: `ops.ndim` returned a symbolic placeholder for dynamic-batch Functional-model inputs, crashing `circle`/`CircleLoss` with a cryptic backend error.
- **Impact:** broke a documented loss function for an entire class of models — any dynamic-batch Functional model, not an edge case.
- Two earlier PRs ([#23215](https://github.com/keras-team/keras/pull/23215) path-traversal hardening, [#23216](https://github.com/keras-team/keras/pull/23216) container weight-path stabilization) were reviewed and closed unmerged.

### Co-authored credit (not in contributor graph)

#### [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) ⭐ 50.9k — Claude Code academic-paper skill suite
Submitted a GitHub Copilot compatibility concept ([#457](https://github.com/Imbad0202/academic-research-skills/pull/457)); the maintainer liked the pointer-file approach and rebuilt it with corrections as [#465](https://github.com/Imbad0202/academic-research-skills/pull/465) (merged), crediting the idea via `Co-authored-by`.
- **Note:** GitHub's contributor graph is built from the git author field only and omits co-author trailers — this credit is real and verifiable in the merged commit, but will not show as a contributor avatar.
- A small regex-escaping fix is open now ([#956](https://github.com/Imbad0202/academic-research-skills/pull/956)); two earlier utility-mode PRs were closed as architectural mismatches with the repo's thin-trigger pattern.

### Under review

<!-- OSS-TABLE:START -->
| Repo | Stars | PR | What it fixes |
|---|---|---|---|
| [InsightSoftwareConsortium/ITK](https://github.com/InsightSoftwareConsortium/ITK) | 1.7k | [#6937](https://github.com/InsightSoftwareConsortium/ITK/pull/6937) | BUG: Fix axis order in image_from_xarray origin/spacing |
| [alphaXiv/OpenResearch](https://github.com/alphaXiv/OpenResearch) | 6.8k | [#585](https://github.com/alphaXiv/OpenResearch/pull/585) | Remove dead statusColor helper that had drifted from StatusBadge |
| [InsightSoftwareConsortium/ITK](https://github.com/InsightSoftwareConsortium/ITK) | 1.7k | [#6936](https://github.com/InsightSoftwareConsortium/ITK/pull/6936) | BUG: Fix transform_from_dict composite dimension lookup |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | 50.9k | [#956](https://github.com/Imbad0202/academic-research-skills/pull/956) | fix(tests): use raw string for regex match to avoid invalid escape warning |
| [scverse/scanpy](https://github.com/scverse/scanpy) | 2.6k | [#4401](https://github.com/scverse/scanpy/pull/4401) | Fix Ingest truncating to settings.N_PCS even when pp.neighbors used more PCs |
| [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) | 203 | [#78](https://github.com/neuralinkcorp/datarepo/pull/78) | Escape values in the generated SQL-filter catalog snippet |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2645](https://github.com/NVIDIA/Model-Optimizer/pull/2645) | fix(distill): flatten MFTLoss labels along with the logits |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2583](https://github.com/NVIDIA/Model-Optimizer/pull/2583) | fix(onnx): move a negative DequantizeLinear axis when transposing the weight |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2575](https://github.com/NVIDIA/Model-Optimizer/pull/2575) | fix(autocast): do not lose magnitude or sign when narrowing initializers |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2567](https://github.com/NVIDIA/Model-Optimizer/pull/2567) | fix(onnx): keep the converted weight's type in step with its zero point |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.4k | [#1518](https://github.com/TorchIO-project/torchio/pull/1518) | Compute normalization statistics per sample |
| [Project-MONAI/MONAI](https://github.com/Project-MONAI/MONAI) | 8.8k | [#9134](https://github.com/Project-MONAI/MONAI/pull/9134) | Fix MeanIoU ignore_index to exclude voxels, not just a channel |
| [pydicom/pydicom](https://github.com/pydicom/pydicom) | 2.2k | [#2382](https://github.com/pydicom/pydicom/pull/2382) | Clamp LUT indices before narrowing the index dtype |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2554](https://github.com/NVIDIA/Model-Optimizer/pull/2554) | fix(onnx): trace Transpose between DequantizeLinear and its consumer in qdq_to_dq |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.2k | [#2553](https://github.com/NVIDIA/Model-Optimizer/pull/2553) | fix(autocast): stream calibration batches instead of materializing all of them |
| [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch) | 3.8k | [#131](https://github.com/jordan-gibbs/hyperresearch/pull/131) | perf: vectorize semantic_search's cosine scan with numpy (#59) |
| [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | 74.1k | [#3239](https://github.com/ruvnet/ruflo/pull/3239) | fix(daemon): read config_set's values envelope in config.json reader |
| [MIC-DKFZ/nnUNet](https://github.com/MIC-DKFZ/nnUNet) | 8.9k | [#3049](https://github.com/MIC-DKFZ/nnUNet/pull/3049) | Harden trainer lookup against phantom module import failures |
| [galaxyproject/galaxy](https://github.com/galaxyproject/galaxy) | 1.9k | [#23058](https://github.com/galaxyproject/galaxy/pull/23058) | Validate matched multi-input expansion errors before async job prep |
| [scverse/anndata](https://github.com/scverse/anndata) | 775 | [#2517](https://github.com/scverse/anndata/pull/2517) | test(backed): add regression for filename=None after read_h5ad |
<!-- OSS-TABLE:END -->

## Contact

- Email: sn3199@columbia.edu
- LinkedIn: https://www.linkedin.com/in/nanda-siddhardha/
- Medium: https://medium.com/@nandasiddhardha
- ResearchGate: https://researchgate.net/profile/Nanda-Siddhardha

