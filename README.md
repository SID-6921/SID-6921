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
- Keep models clinically interpretable, not only statistically strong.
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

I find bugs by reading code and comparing sibling functions, not by picking issues off a tracker. I reproduce each fix below locally before submitting it.

<!-- OSS-STATS:START -->
**Snapshot:** 32 repos where I am a credited contributor through merged commits, plus 1 co-authored credit counted separately below. 84 merged PRs. ~58 open PRs under review.
<!-- OSS-STATS:END -->

<!-- FEATURED-REPO:START -->
📈 **Trending this run:** [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) gained +166 ⭐ since the last check (now 23.4k ⭐ total). Recomputed daily from a real snapshot, not a guess.
<!-- FEATURED-REPO:END -->

### Contributor repos (merged)

#### [MakazhanAlpamys/Soup](https://github.com/MakazhanAlpamys/Soup) ⭐ 10.8k 🔥 +31 today — LLM fine-tuning CLI
14 merged PRs. [#625](https://github.com/MakazhanAlpamys/Soup/pull/625) consolidated a duplicated SSRF loopback/private-host predicate copied across four files, after the same gap let a fix land in one copy and not the others three times before. [#637](https://github.com/MakazhanAlpamys/Soup/pull/637) added a snapshot test pinning what each of 162 recipes resolves to, since nothing previously caught a schema-default change silently retuning every recipe that relied on it. [#640](https://github.com/MakazhanAlpamys/Soup/pull/640) delta-encoded that snapshot fixture against a shared baseline, so a schema-default change reddens only the recipes it affects instead of all 162 identically. [#639](https://github.com/MakazhanAlpamys/Soup/pull/639) fixed checkpoint auto-detection recognizing only the transformers/unsloth directory shape, so an MLX run's own step-numbered adapter files never matched and `--resume` silently restarted from scratch. [#747](https://github.com/MakazhanAlpamys/Soup/pull/747) added the one unproven acceptance test for LoRA+ resume, a full save/resume round trip confirming optimizer momentum and scheduler LR survive, after finding the wiring itself already correct. [#767](https://github.com/MakazhanAlpamys/Soup/pull/767) widened `soup train`'s failure boundary so a setup-phase exception reaches `fail_run` instead of leaving the run row stuck at `status='running'` forever, 220 of 432 runs on the reporting database were stuck this way. [#864](https://github.com/MakazhanAlpamys/Soup/pull/864) added two GRPO recipe templates following the project's existing conventions for that recipe family. [#869](https://github.com/MakazhanAlpamys/Soup/pull/869) made `soup data validate --format bogus` reject an unrecognized format instead of reporting every row valid, the same silent-pass failure mode two prior fixes had already closed for a different case. [#950](https://github.com/MakazhanAlpamys/Soup/pull/950) fixed the MLX teacher worker's identity check comparing the parent's own process handle to the worker's reported PID, which differ on Windows because the venv launcher spawns the real interpreter as a grandchild, switching to a generated nonce the child echoes back instead. [#998](https://github.com/MakazhanAlpamys/Soup/pull/998) rewrote two doc pages describing four `--minillm-*` CLI flags that do not exist, to show the YAML config fields that work instead. [#1370](https://github.com/MakazhanAlpamys/Soup/pull/1370) fixed an Anthropic provider failure message naming the ignored `--base-url` value instead of the fixed endpoint Anthropic always uses. [#1544](https://github.com/MakazhanAlpamys/Soup/pull/1544) found and fixed 76 tests across 10 files silently depending on live Hugging Face Hub downloads, over three times the issue's own grep-based estimate of about 21. [#1663](https://github.com/MakazhanAlpamys/Soup/pull/1663) made the stripe-root validation re-run before every per-layer write instead of once up front, closing the window during which a renamed, swapped stripe root went undetected mid-write. [#2690](https://github.com/MakazhanAlpamys/Soup/pull/2690) added a stat-before-read size check to the airgap bundler's file hashing, which previously streamed an oversized file through SHA-256 in full before the size cap ever triggered, the same guard a sibling `_hash_file` helper already had.
- **Impact:** #625 closed a loopback and private-host bypass across the whole request path, not one call site. #1663 turned a silent data-corruption window into a surfaced, refused failure, through a maintainer-found volume-mount-point edge case I reproduced and fixed live. #2690 closed a sibling-inconsistency with the repo's own `adapter_sign._hash_file`. #767's stuck-run bug affected roughly half the runs on the reporting database. #950's Windows-only PID mismatch would otherwise silently discard a completed MLX training run as a false failure.
- **Scope:** The largest body of work here by PR count. Several of the 14 are test-infrastructure and fixture reworks (#637, #640, #747, #1544), not user-facing bug fixes.
- **Severity:** 4/5 for #625, #1663, and #2690, a real exploit path and two silent-corruption windows. 3/5 for #639, #767, #869, and #950, each a silent wrong-behavior case on a routine path. 1/5 for #864, #998, and #1370, a new recipe pair and two messaging/documentation fixes.

#### [Project-MONAI/MONAI](https://github.com/Project-MONAI/MONAI) ⭐ 8.9k 🔥 +7 today — medical imaging DL framework
3 merged PRs in the metrics module. [#8956](https://github.com/Project-MONAI/MONAI/pull/8956) fixed a divide-by-zero in the pydicom affine computation for single-slice volumes. [#9134](https://github.com/Project-MONAI/MONAI/pull/9134) fixed `MeanIoU`'s `ignore_index` zeroing a whole channel instead of masking voxels, so it disagreed with `compute_dice()` on identical input, 1.0 versus 0.667, despite sharing the same docstring wording, and had shipped untested since PR #8757. [#9171](https://github.com/Project-MONAI/MONAI/pull/9171) fixed the same class of gap one level deeper: `DiceHelper`'s `per_component` connected-component path never received the `ignore_index` mask the regular per-channel path already applies, so combining the two options silently scored ignored voxels as if nothing were ignored.
- **Impact:** #8956 hit single-slice DICOM series, localizers and scouts, which are routine in practice, crashing instead of producing a usable affine. #9134 and #9171 both produce a silently wrong metric value with no error, the worse failure mode in a library used to report a model's accuracy.
- #9134 and #9171 were both found through sibling comparison across MONAI's own metric functions, which kept making the same category of mistake in a new corner of the same module.
- **Severity:** 4/5 across all three. Single-slice volumes are routine, not an edge case, and a silently wrong metric is worse than a crash.

#### [alphaXiv/OpenResearch](https://github.com/alphaXiv/OpenResearch) ⭐ 8.6k 🔥 +5 today — research-paper reading platform
2 merged PRs. [#351](https://github.com/alphaXiv/OpenResearch/pull/351) added a full Hindi (hi) locale, +1,413/−229 across 6 files. [#585](https://github.com/alphaXiv/OpenResearch/pull/585) removed a dead `statusColor` helper that had drifted out of sync with `StatusBadge`, confirmed unused through a repo-wide grep including wildcard re-export paths.
- **Impact:** #351 covers UI strings end-to-end instead of a partial translation, the largest locale contribution on the repo at the time. #585 removed dead code that was otherwise free to keep silently diverging from the component it was meant to mirror.
- **Severity:** 2/5 for #351, a feature gap, not a correctness bug. The product was unusable in Hindi, not broken. 1/5 for #585, a cleanup with no behavior change.

#### [nipy/nibabel](https://github.com/nipy/nibabel) ⭐ 809 — neuroimaging I/O library
5 merged PRs. [#1553](https://github.com/nipy/nibabel/pull/1553) generalized `rescale_affine()` to non-4x4 affines. It had been hardcoded to `affine[:3,:3]` despite being documented for arbitrary `(N,N)`. [#1562](https://github.com/nipy/nibabel/pull/1562) added shape validation to `Nifti1Header.set_sform`. [#1596](https://github.com/nipy/nibabel/pull/1596) added the missing lower-bound and non-negative-dimension checks to `SpatialHeader.set_zooms`, which validated that zoom values were positive but let a wrong-length zoom sequence through unchecked. [#1616](https://github.com/nipy/nibabel/pull/1616) improved `MGHHeader.set_zooms`'s error message for a too-short zoom list, matching how its siblings `AnalyzeHeader.set_zooms` and `SpatialHeader.set_zooms` already validate length exactly rather than only an upper bound. [#1572](https://github.com/nipy/nibabel/pull/1572) added my entry to `CITATION.cff`.
- **Impact:** #1553 fixed a function that raised on any non-square-4 input despite its own docstring promising general support, a gap between the docs and the implementation. #1596 closed the same validation gap `set_zooms` already had, in a different header class. #1616 turned a confusing length mismatch into a clear error.
- Found through sibling-function comparison across the header classes' own `set_zooms` implementations, and `rescale_affine` versus `voxel_sizes`.
- **Severity:** 3/5. Hard crashes or silently-accepted invalid input on documented or otherwise-valid cases, each limited to one specific header class or affine shape.

#### [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) ⭐ 213 — data-table/query library
3 merged PRs. [#75](https://github.com/neuralinkcorp/datarepo/pull/75) added missing `is null`/`is not null` filter support on `ParquetTable`, already present for Clickhouse and Delta. [#76](https://github.com/neuralinkcorp/datarepo/pull/76) replaced a bare dict-subscript `KeyError` with a clear error for unsupported ROAPI partition column types. [#78](https://github.com/neuralinkcorp/datarepo/pull/78) fixed unescaped SQL interpolation in a generated filter-catalog snippet, an injection-shaped bug in generated code.
- **Impact:** #75 closed a feature gap between three backends meant to share one filter contract. #76 turned an opaque internal exception into an actionable error. #78 closed a real SQL-injection-shaped path in generated code.
- **Severity:** 4/5 for #78. Unescaped SQL interpolation is injection-shaped regardless of where it is generated. 2/5 for #75 and #76, a missing feature and an opaque error, annoying but not dangerous.

#### [InsightSoftwareConsortium/ITK](https://github.com/InsightSoftwareConsortium/ITK) ⭐ 1.7k — medical image processing toolkit
7 merged PRs. [#6932](https://github.com/InsightSoftwareConsortium/ITK/pull/6932) merged same day as opened: `array_view_from_vnl_vector` aliased the deep-copy function instead of the documented view/no-copy function. [#6936](https://github.com/InsightSoftwareConsortium/ITK/pull/6936) fixed a `TypeError` in `transform_from_dict` for composite, multi-step transforms. [#6937](https://github.com/InsightSoftwareConsortium/ITK/pull/6937) fixed `image_from_xarray()` assigning origin and spacing to the wrong axes on 4D images. [#6953](https://github.com/InsightSoftwareConsortium/ITK/pull/6953) fixed `ITKClass.__eq__` comparing only 9 of 10 fields, missing `has_superclass`, which let stub-generation caching reuse a stale pickle. [#6954](https://github.com/InsightSoftwareConsortium/ITK/pull/6954) fixed a pixelType string typo, `SymmetrySecondRankTensor` versus `SymmetricSecondRankTensor`, that broke the WASM round trip for tensor images. [#6996](https://github.com/InsightSoftwareConsortium/ITK/pull/6996) fixed `image_from_vtk_image` trimming a trailing size-1 z dimension for vector-pixel images but not scalar images, so a 2D scalar image round-tripped through VTK came back 3D. [#7151](https://github.com/InsightSoftwareConsortium/ITK/pull/7151) replaced a bare `KeyError('unknown')` in `itk.imread` with a message naming the reported component type and pointing at the fix.
- **Impact:** #6932 silently broke a documented no-copy contract. Callers relying on in-place mutation through the view got a disconnected copy, with no error raised. #6953, #6954, and #6996 are each a sibling-function inconsistency, one code path handled a case correctly, a nearly identical path next to it did not. #7151 turned an opaque crash into an actionable error.
- **Why this repo matters:** ITK started as a US National Institutes of Health (NIH)-funded project in 1999. It is now a standard medical-imaging toolkit in academic and clinical research worldwide, including groups across the US and India. A silent bug here does not stay theoretical. It sits underneath someone's real imaging pipeline.
- **Severity:** 4/5 for #6932 and #6996, each a silent wrong result with no error raised. 3/5 for #6953 and #6954, a stale cache and a round-trip crash, each confined to one code path. 2/5 for #6936, #6937, and #7151, a clear crash or opaque error, not a silent one.

#### [keras-team/keras](https://github.com/keras-team/keras) ⭐ 64.5k 🔥 +5 today
2 merged PRs. [#23860](https://github.com/keras-team/keras/pull/23860) fixed `ops.ndim` returning a symbolic placeholder for dynamic-batch Functional-model inputs, crashing `circle`/`CircleLoss` with a cryptic backend error. [#24201](https://github.com/keras-team/keras/pull/24201) fixed the numpy backend's `divide_no_nan` raising a spurious `RuntimeWarning` on a zero divisor, a case the jax, torch, and TensorFlow backends already handle without warning.
- **Impact:** #23860 broke a documented loss function for an entire class of models. Any dynamic-batch Functional model hits this, not an edge case. #24201 is a sibling-inconsistency between keras's own backends, numpy warned on a case the other three backends treat as routine and already guard against.
- Two earlier PRs ([#23215](https://github.com/keras-team/keras/pull/23215), path-traversal hardening, and [#23216](https://github.com/keras-team/keras/pull/23216), container weight-path stabilization) were reviewed and closed unmerged.
- **Severity:** 4/5 for #23860. Not an edge case, every dynamic-batch Functional model hitting this loss function would crash. 2/5 for #24201, a spurious warning under `warnings.simplefilter("error")`, not a wrong result.

#### [unstablebuild/rune](https://github.com/unstablebuild/rune) ⭐ 1.8k 🔥 +3 today — GPU-accelerated IDE and terminal multiplexer
[#219](https://github.com/unstablebuild/rune/pull/219) merged: `BuildPluginArgv`'s `sh -c` fallback joined task args with a plain space, so an empty-string argument collapsed into nothing and silently shifted every later argument one position left.
- **Impact:** Reachable from ordinary task config. `internal/ide/idetask` builds a task's command directly from user-authored `Args []string` with no guard against an embedded empty string, so a config with one empty arg ran the wrong command with no error.
- **Severity:** 3/5. A silent argument shift a user would blame on their own config rather than a crash, but reachable from normal usage, not a contrived input.

#### [MRtrix3/mrtrix3](https://github.com/MRtrix3/mrtrix3) ⭐ 359 — MRtrix3 provides a set of tools to perform various advanced diffusion MRI analyses, including constrained spherical deconvolution (CSD), probabilistic tractography, track-density imaging, and apparent fibre density
3 merged PRs, each a distinct silent-correctness bug in a different CLI tool. [#3450](https://github.com/MRtrix3/mrtrix3/pull/3450) fixed an off-by-one bounds check in `toggle_axis()` that indexed one past the vector instead of growing it. [#3449](https://github.com/MRtrix3/mrtrix3/pull/3449) fixed `mrfilter` silently swapping the user's `-zupper`/`-zlower` threshold values. [#3448](https://github.com/MRtrix3/mrtrix3/pull/3448) fixed `phaseencoding` raising a wrong "unrecognized" error on a numeric axis specifier documented as valid for `dwifslpreproc -pe_dir`.
- **Impact:** #3449 silently inverted a user-supplied cleaning threshold whenever upper and lower differ, with no error. #3448 rejected documented-valid CLI input with a misleading error message.
- **Severity:** 3/5. Two of the three are silent wrong-behavior bugs rather than crashes, each scoped to one specific CLI path.

#### [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) ⭐ 5.7k 🔥 +4 today — A unified library of SOTA model optimization techniques like quantization, distillation, pruning, neural architecture search, speculative decoding, etc. It compresses deep learning models for downstream deployment frameworks like TensorRT-LLM, TensorRT, vLLM, etc. to optimize inference speed.
6 merged PRs in quantization and distillation. [#2645](https://github.com/NVIDIA/Model-Optimizer/pull/2645) fixed `MFTLoss` raising on the ordinary `(batch, seq_len, vocab)` logit shape a language model produces, despite its own docstring allowing it. [#2583](https://github.com/NVIDIA/Model-Optimizer/pull/2583) fixed a negative ONNX `DequantizeLinear` axis, legal per the ONNX spec, being mis-handled when transposing a per-channel-quantized weight. [#2554](https://github.com/NVIDIA/Model-Optimizer/pull/2554) fixed weight-quantization conversion crashing when a `Transpose` sits between `DequantizeLinear` and its consumer, as in MaxViT's attention blocks. [#2567](https://github.com/NVIDIA/Model-Optimizer/pull/2567) fixed `qdq_to_dq()` always writing a converted weight as `int8` regardless of the source zero point's real type, so an unsigned zero point left the weight and zero point disagreeing on type. [#2553](https://github.com/NVIDIA/Model-Optimizer/pull/2553) fixed `ReferenceRunner.run()` retaining one full-graph activation dump per calibration sample, then copying that data a second time before aggregation, so peak memory grew linearly with the calibration set size. [#2575](https://github.com/NVIDIA/Model-Optimizer/pull/2575) fixed AutoCast's FP64-to-FP32 initializer narrowing turning an out-of-range value like `DBL_MAX` into infinity, and a separate underflow path that replaced a too-small value with the target type's smallest subnormal but dropped its sign.
- **Impact:** #2583 matters most. On a square weight, a negative axis converted silently to a model that **runs but computes the wrong output** (max diff 4.09 in the PR's own check), with nothing to flag it. #2645 blocked Minifinetuning-style distillation (arXiv:2506.15702) from working at all on real LM-shaped tensors. #2567 produced a graph `onnx.checker` accepts but ONNX Runtime rejects, silently losing the top half of an unsigned weight's value range. #2553 was the direct cause of the out-of-memory failure reported in issue #2337. #2575's infinity does not stay put, it turns into a NaN at the first `inf - inf` downstream, and `DBL_MAX` is an ordinary way to spell "no bound" on a `Clip`, so this was reachable from a valid FP64 model.
- **Severity:** 4/5. #2583, #2567, and #2575 each produce a silently wrong or sign-flipped numeric result on routine input, the highest-risk kind of bug in a quantization library, and that sets the bar for this group.

#### [galaxyproject/galaxy](https://github.com/galaxyproject/galaxy) ⭐ 1.9k 🔥 +1 today — Data intensive science for everyone.
2 merged PRs. [#23058](https://github.com/galaxyproject/galaxy/pull/23058) made malformed matched-input tool requests raise a clear `RequestParameterInvalidException` at the API/tool-expansion boundary instead of reaching async job prep. [#24829](https://github.com/galaxyproject/galaxy/pull/24829) fixed `assert_element_text_is` and `assert_attribute_is` anchoring only the end of their regex, so a tool test asserting text `"blastp"` passed against actual output `"superblastp"`.
- **Impact:** #23058: per issue #22884, malformed matched-input requests were reaching Celery async job prep and surfacing as noisy internal errors instead of a clean request-validation error. #24829 silently hid real tool-output regressions instead of catching them, in test-verification code whose entire job is to catch that kind of regression.
- **Severity:** 2/5 for #23058, turns an opaque internal error into a clear one, does not change what's ultimately rejected. 3/5 for #24829, a verification assertion that does not verify what it claims to.

#### [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) ⭐ 23.4k 🔥 +166 today — Open-source plugin for designing and reviewing software with agents
[#439](https://github.com/google/elephant-goldfish-model/pull/439) merged: the bot's own ping-abuse guard wraps bare `@user`/`@org/team` mentions in backticks before posting a PR-review comment. A stray unpaired backtick inside a fenced code block bypassed it, since the stray backtick paired across the fence with an unrelated one and let a real `@mention` sitting between them slip through un-neutralized.
- **Impact:** A crafted PR comment, prose mentioning a shell backtick for example, got the bot to ping someone irrelevant to the PR, defeating the guard's purpose.
- **Severity:** 3/5. A real bypass of an explicit anti-abuse guard, limited to unwanted notifications rather than data exposure.

#### [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch) ⭐ 5.1k 🔥 +19 today — Convert Claude Code or Codex into the most intelligent Deep Research Agent. Collect, search, and synthesize web research into a persistent, searchable wiki that builds on itself. Hosted API + MCP: hyperresearch.ai
2 merged PRs. [#202](https://github.com/jordan-gibbs/hyperresearch/pull/202) fixed the citation-density ship-gate counting every bracketed reference in a report's own Sources/References listing, not only its body. [#131](https://github.com/jordan-gibbs/hyperresearch/pull/131) vectorized `semantic_search`'s per-candidate cosine scoring into a single numpy matmul, per the maintainer's own ask in #59.
- **Impact:** #202 meant a report whose body made claims with few or no real citations still cleared the citation-density floor purely because its bibliography had many numbered entries, the exact failure mode the gate exists to catch.
- **Severity:** 3/5 for #202, a quality gate silently passing what it exists to catch. 2/5 for #131, pure performance with no behavior change.

#### [nilearn/nilearn](https://github.com/nilearn/nilearn) ⭐ 1.5k — Machine learning for NeuroImaging in Python
2 merged PRs. [#6709](https://github.com/nilearn/nilearn/pull/6709) fixed `clean_img` reshaping its output using the raw `sample_mask` argument's shape instead of `clean()`'s actual output shape. [#6726](https://github.com/nilearn/nilearn/pull/6726) fixed the multi-image maskers merging high-variance confounds into a per-image `list`/`tuple` confound entry with `confounds[i] += hv_confounds`, which falls through to `ndarray.__radd__` and tries to broadcast-add instead of appending the new confound source.
- **Impact:** #6709 crashed with `ValueError: cannot reshape array` whenever a boolean `sample_mask` was passed without `mask_img`, a combination `clean()`'s own docs describe as valid. #6726 raised a shape-mismatch error on the exact `list`/`tuple` confound format the maskers' own docstring documents as valid, whenever `high_variance_confounds=True`.
- **Severity:** 3/5 for both. Hard crashes on documented-valid input, each scoped to one specific argument combination.

#### [pydicom/pydicom](https://github.com/pydicom/pydicom) ⭐ 2.2k 🔥 +1 today — Read, modify and write DICOM files with python code
2 merged PRs. [#2428](https://github.com/pydicom/pydicom/pull/2428) mirrored `DSfloat`'s NaN-equality fix onto `DSdecimal`, so two NaN-valued DS elements compare equal under `config.use_DS_decimal = True` too. [#2382](https://github.com/pydicom/pydicom/pull/2382) fixed `apply_voi()`/`apply_modality_lut()` casting LUT indices into a too-narrow dtype before clipping, so out-of-range values wrapped instead of being clamped.
- **Impact:** #2428 broke structural dataset-equality checks (`ds == deepcopy(ds)`) for the decimal backing class specifically. #2382 made an 8-bit LUT with 4096 entries, the routine way to display 12-bit data on an 8-bit display, silently return wrong pixel values with no warning.
- **Severity:** 4/5. #2382 is silently-wrong image data on a routine clinical-display path, not an edge case. #2428 is a narrower equality-comparison gap.

#### [scverse/scanpy](https://github.com/scverse/scanpy) ⭐ 2.6k — Single-cell analysis in Python. Scales to >100M cells.
[#4401](https://github.com/scverse/scanpy/pull/4401) merged: `Ingest` fell back to a hardcoded `settings.N_PCS` (50) whenever the reference `adata`'s stored neighbor params recorded neither `use_rep` nor `n_pcs`, exactly the state `pp.neighbors()` leaves with its own defaults.
- **Impact:** Whenever more than 50 PCs were computed, for example `sc.pp.pca(adata, n_comps=100)`, `Ingest` silently built its KNN index in a different, truncated representation than the one that produced the reference neighbor graph. No error, only a quietly wrong embedding and label mapping for `sc.tl.ingest`.
- **Severity:** 4/5. Silent wrong output on a default, common code path, found through sibling-branch comparison with the function that computes the real representation.

#### [udgamlabs/gargi](https://github.com/udgamlabs/gargi) ⭐ 3 — Gargi: a 384M-parameter English language model trained from scratch on ~17B tokens. Docs, runnable examples and checksums; weights on Hugging Face.
[#1](https://github.com/udgamlabs/gargi/pull/1) merged: the Ollama quick-start comment said thinking was off by default, the opposite of what the model's own `Modelfile` and example script document.
- **Impact:** A new user following the README as written would run the wrong command and have no documented way to disable thinking.
- **Severity:** 1/5. Documentation-only, no code behavior changed.

#### [udgamlabs/hinglish-commands-0.6b](https://github.com/udgamlabs/hinglish-commands-0.6b) ⭐ 0 — English and Romanized Hinglish commands to structured JSON. A small Qwen3 adapter, reproducible benchmarks, and a local demo.
2 merged PRs. [#1](https://github.com/udgamlabs/hinglish-commands-0.6b/pull/1) fixed `validate_model_card()` dynamically loading a helper script that isn't present in the repo or its history, failing with a raw `FileNotFoundError` from inside `importlib`. [#2](https://github.com/udgamlabs/hinglish-commands-0.6b/pull/2) fixed the local demo server accepting unlimited concurrent connections with no cap, since its per-read socket timeout does not bound a connection's total lifetime, so a client sending data slowly enough holds a handler thread open indefinitely.
- **Impact:** #1 made the documented `--model-card-dir` flag crash with an opaque internal error instead of a clear, actionable one. #2 left a loopback-only resource-exhaustion gap: a slow-trickle local client exhausts the server's thread pool, though the existing Host and Origin checks keep it from reaching a remote attacker.
- **Severity:** 1/5 for #1, error-message clarity only. 2/5 for #2, a real but access-limited resource-exhaustion gap.

#### [udgamlabs/shruti](https://github.com/udgamlabs/shruti) ⭐ 13 — Shruti: 29.5 MB speech-to-text for Hindi, English and Hinglish that runs offline on a phone, a laptop or in the browser. Built on Cactus Whistle. Docs, runnable examples and checksums; weights on Hugging Face.
[#1](https://github.com/udgamlabs/shruti/pull/1) merged: the browser demo's `getModel()` only checked a 4-byte magic number on a Cache Storage hit, skipping the SHA-256 check that the Python/shell paths always run.
- **Impact:** The model URL points at a mutable `main` ref, so a returning browser user with the old file cached would keep silently running a stale, mismatched model with no warning if the upstream model were ever replaced.
- **Severity:** 2/5. A real silent-staleness gap, conditional on the upstream model changing.

#### [udgamlabs/udgam-384m](https://github.com/udgamlabs/udgam-384m) ⭐ 0 — Udgam-384M: a 384M-parameter English model for on-device tool calling, trained from scratch. Docs, runnable examples and checksums; weights on Hugging Face.
3 merged PRs. [#1](https://github.com/udgamlabs/udgam-384m/pull/1) fixed `transformers_tool_call.py`, the one of three tool-calling examples that executed the model's chosen tool name without checking it against an allowlist first, unlike its two siblings. [#2](https://github.com/udgamlabs/udgam-384m/pull/2) fixed `llama_server_tool_call.py` executing any tool the model called, including a message-sending tool, with no confirmation, despite its own docstring saying to confirm risky ones. [#3](https://github.com/udgamlabs/udgam-384m/pull/3) fixed `gemma4_tools.py`'s hand-rolled tool-call parser re-slicing the remaining input on nearly every character, an O(n^2) parse over raw, unbounded model output.
- **Impact:** #1 and #2 are the same gap in two siblings: an example meant to demonstrate safe tool-calling practice skipped the confirmation or allowlist guard its sibling examples already use. #3 made a long or malformed tool call take seconds to tens of seconds to parse, scaling quadratically with the length of raw model output.
- **Severity:** 2/5 for #1 and #2, example and demo code, not a library path. 3/5 for #3, a real performance cliff tied to input length, though limited to example and template code.

#### [udgamlabs/vemana](https://github.com/udgamlabs/vemana) ⭐ 9 — Vemana: a 278M Telugu language model trained from scratch, by Udgam Labs
2 merged PRs. [#1](https://github.com/udgamlabs/vemana/pull/1) fixed `llama_greedy` and `llama_ppl` running their `llama.cpp` subprocess without checking its exit status, unlike their near-identical sibling `llama_ids`. [#2](https://github.com/udgamlabs/vemana/pull/2) fixed two sites in `check_gguf.py` that each created a `NamedTemporaryFile(delete=False, ...)` and never removed it afterward, leaking up to 40 files per GGUF argument on every run at the default page count.
- **Impact:** #1 meant a crashed or missing `llama.cpp` binary silently produced empty output, reported as a spurious greedy-text or perplexity regression indistinguishable from an actual model problem. #2 accumulated temp files run after run with no cleanup.
- **Severity:** 2/5 for both. #1 is a false-signal diagnostics bug. #2 is a disk-space leak, not data loss.

#### [NeuroTechX/moabb](https://github.com/NeuroTechX/moabb) ⭐ 1.1k 🔥 +1 today — Mother of All BCI Benchmarks
[#1361](https://github.com/NeuroTechX/moabb/pull/1361) merged: `MotorImagery.used_events` collected every event in a dataset regardless of `n_classes`, while its sibling `FilterBankMotorImagery.used_events` correctly stopped once it reached `n_classes`.
- **Impact:** A user who set `n_classes` on `MotorImagery` without an explicit `events` list silently got however many classes the dataset had, not the number requested, since the unfiltered result fed directly into `EventsToLabels` with no truncation downstream.
- Found through sibling-function comparison between the two paradigm classes.
- **Severity:** 3/5. Silent wrong behavior on a parameter the user sets directly, scoped to the `events=None` path.

#### [SpikeInterface/spikeinterface](https://github.com/SpikeInterface/spikeinterface) ⭐ 880 — spike sorting pipelines
[#4943](https://github.com/SpikeInterface/spikeinterface/pull/4943) merged: `compute_amplitude_cutoffs()`'s own `num_histogram_bins` default stayed at 500, while its own docstring, its sibling `AmplitudeCutoff.metric_params`, and the low-level helper it wraps all default to 100.
- **Impact:** With `amplitudes_bins_min_ratio=5`, the stale default silently raised the spike-count floor a unit needs before `amplitude_cutoff` stops returning `NaN`, from 500 spikes to 2500 spikes, for anyone calling the function directly without an explicit override. A prior fix (#4415) corrected the sibling defaults after a regression but missed this one.
- **Severity:** 3/5. Silent `NaN` results on a routine quality-metrics call, likely to be mistaken for a data problem rather than a stale default.

#### [udgamlabs/chitra-tiny](https://github.com/udgamlabs/chitra-tiny) ⭐ 0 — Chitra Tiny: a 212M-parameter text-to-image model (256 px) trained from scratch
[#1](https://github.com/udgamlabs/chitra-tiny/pull/1) merged: `app.py` decided between a local checkpoint and the hub repo by checking only for `model.safetensors`, while `from_pretrained` requires both that file and `config.json` once it takes the local-path branch.
- **Impact:** A local folder with weights but no config, from a partial download or a hand-copied checkpoint, crashed the app with an unhandled `FileNotFoundError` instead of falling back to the hub download.
- **Severity:** 2/5. A crash on an incomplete local checkout, with no graceful fallback where one already existed for the normal case.

#### [udgamlabs/laghu](https://github.com/udgamlabs/laghu) ⭐ 1 — Laghu: a 152M chat model trained from scratch for $146
Found during an audit pass over the training, eval, and data-prep scripts, bundled into one PR: [#1](https://github.com/udgamlabs/laghu/pull/1) fixed four separate issues.
- **Impact:** The most severe is unsandboxed code execution. `gsm_eval.py` ran model-generated code with a raw `exec()` and real builtins, inside a forked copy of the live training process, on every evaluation step by default, despite the repo already having a sandboxed `execute_code` helper built for exactly this. The other three: a contamination check that only marked one of several duplicate positions in a sorted probe array, an audit statistic that ignored the resumed-shard row offset, and an SFT document scanner with no deduplication, unlike its sibling scanner.
- **Severity:** 4/5. Running untrusted model output with no sandboxing during ordinary training is a real execution-boundary gap.

#### [udgamlabs/lilavati](https://github.com/udgamlabs/lilavati) ⭐ 0 — Lilavati: a 95M model that solves maths word problems by writing Python
2 merged PRs. [#1](https://github.com/udgamlabs/lilavati/pull/1) fixed `eval/gsm8k.py` never closing or flushing its results file, so an interrupted run, a Ctrl-C, an OOM-kill, a dropped SSH session, left the file truncated or empty even after most problems had been scored. [#2](https://github.com/udgamlabs/lilavati/pull/2) fixed the sandboxed-execution structure check rejecting any solution using `try`/`except ZeroDivisionError`, the most natural defensive pattern for a math problem, even though the sandboxed runtime already exposes that exception for this purpose.
- **Impact:** #1 silently lost real eval progress on any interrupted long run. #2 scored correct, safe solutions as failures purely for using a guard clause the runtime already supports.
- **Severity:** 3/5 for #1, silent data loss on interruption. 2/5 for #2, correct programs scored as wrong, not a security gap.

#### [udgamlabs/phonegpt](https://github.com/udgamlabs/phonegpt) ⭐ 0 — train a small language model on an Android phone's own CPU
[#1](https://github.com/udgamlabs/phonegpt/pull/1) merged: `drop_rng`, the dropout-mask RNG stream, stayed at a hardcoded static seed while its two siblings, the weight-init and batch-sampling RNGs, were both correctly reseeded from `-seed`.
- **Impact:** With dropout enabled, as the README's own training command uses, two runs with different seeds still drew identical dropout masks every step, an undisclosed shared source of correlation between runs meant to be independent, such as seed-variance ablations.
- **Severity:** 2/5. A reproducibility gap in experiment design, not a crash or data-correctness bug.



#### [udgamlabs/drishya-tiny](https://github.com/udgamlabs/drishya-tiny) ⭐ 3 — Drishya Tiny by Udgam Labs: a 212M video generator trained from scratch (text or photo to 2-second video)
[#1](https://github.com/udgamlabs/drishya-tiny/pull/1) merged, two fixes: `make_clip_ids.py` wrote its output CSV directly to the real `--out` path while iterating shards, and only checked the `--expect` row count after all rows were already written. `vbench_generate.py`'s `run_jobs` recovered a job's batch position with `chunk.index(j)`, which falls through to tuple equality.
- **Impact:** A failed `--expect` check in `make_clip_ids.py` left a wrong or partial CSV sitting at the real output path, so a downstream trainer would load it with no indication anything was wrong. In `vbench_generate.py`, two i2v jobs sharing the same `prompt_en` but pointing at different source images made `chunk.index(j)` fall through to comparing image tensors directly, and `PyObject_IsTrue` on a multi-element tensor crashed the entire run with "Boolean value of Tensor with more than one element is ambiguous."
- **Severity:** 3/5. The CSV fix prevents silent partial-data corruption on a failed precondition. The indexing fix turns a real, reachable crash (not a contrived input, since VBench-I2V's own metadata file reuses prompts across images) into correct behavior through an atomic write and an enumerate-based index.

#### [neuropsychology/NeuroKit](https://github.com/neuropsychology/NeuroKit) ⭐ 2.4k — Python toolbox for neurophysiological signal processing
[#1257](https://github.com/neuropsychology/NeuroKit/pull/1257) merged: the legacy 2010 Elgendi QRS detector only emits a detection on a falling edge that closes an open block, so a block still open when the signal ends, meaning the last heartbeat falls near the recording's end, is silently dropped. The newer 2013 variant already handles this exact edge case, with its own regression test.
- **Impact:** Any recording whose last heartbeat lands within the detector's QRS-duration window of the signal's end loses that beat with no warning, an ordinary recording-boundary case, not a contrived input.
- Found through sibling-function comparison between the 2010 and 2013 Elgendi detectors.
- **Severity:** 3/5. Silent data loss on a routine recording shape, in a signal-processing library where a dropped heartbeat is a real correctness problem, not cosmetic.

#### [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) ⭐ 58.8k 🔥 +160 today — Claude Code academic-paper skill suite
5 merged PRs, all authored and merged under my own account, distinct from the co-authored credit below. [#1133](https://github.com/Imbad0202/academic-research-skills/pull/1133) added a Claim Decomposition pass to `source_verification_agent.md`'s factual-claim-verification section, closing issue #1128. [#1132](https://github.com/Imbad0202/academic-research-skills/pull/1132) fixed the committee-correspondence pointer test covering four pointer files but missing a fifth, `commands/ars-revision-coach.md`, which also carried a paraphrased pointer sentence instead of the canonical one the other four files use. [#965](https://github.com/Imbad0202/academic-research-skills/pull/965) fixed a paired `exception`/`exception_reason` lint check treating a null `exception_reason` as present, since `str(None)` is the non-empty string `"None"`, a bug a sibling validator had already fixed but this file never received. [#963](https://github.com/Imbad0202/academic-research-skills/pull/963) fixed a fixture-manifest lint comparing paths with `str(Path)` instead of `.as_posix()`, so on Windows every git-tracked fixture file reported as an orphan even when correctly declared. [#956](https://github.com/Imbad0202/academic-research-skills/pull/956) fixed a test's `match=` regex passed as a plain string instead of raw, the lone outlier against every other regex in the suite and a pattern Python is moving toward rejecting outright.
- **Impact:** #1133 closed a real capability gap the maintainer had scoped out in #1128. #1132 closed a blind spot in the repo's own compliance check, the exact kind of drift that check exists to catch. #963 made a CI lint fail on every run for a Windows contributor regardless of what they changed. #965 closed the same silent-pass gap its sibling validator had already fixed.
- **Severity:** 1/5 for #1133, #1132, and #956, documentation, test-coverage, and style fixes with no user-facing crash or data risk. 2/5 for #963 and #965, a CI check that gave the wrong answer on a routine input.

#### [wheresryan22/anatomy](https://github.com/wheresryan22/anatomy) ⭐ 29.5k 🔥 +150 today — an agent skill for creating detailed, interactive isometric illustrations of real-world machines and complex systems, generating polished SVGs with optional WebGL shaders and 3D effects
[#64](https://github.com/wheresryan22/anatomy/pull/64) fixed the ripple-tank example's ink colour reading from a hardcoded inline GLSL literal instead of the shared per-theme fixed-uniform object every other tuned constant in the same file already used.
- **Impact:** The repo's own house rules state colours are tokens with a light and dark value, never literals in a figure's shader. This one line had drifted from that rule and from the rest of its own file, low risk to notice by eye since the two themes never render side by side, exactly the kind of inconsistency a line-by-line audit catches.
- **Severity:** 1/5. A plumbing fix with no visual delta, confirmed by rebuilding both themes and diffing the generated HTML.




### Co-authored credit (not in contributor graph)

#### [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) ⭐ 58.8k 🔥 +160 today — Claude Code academic-paper skill suite
Submitted a GitHub Copilot compatibility concept ([#457](https://github.com/Imbad0202/academic-research-skills/pull/457)). The maintainer liked the pointer-file approach and rebuilt it with corrections as [#465](https://github.com/Imbad0202/academic-research-skills/pull/465) (merged), crediting the idea through `Co-authored-by`.
- **Note:** GitHub's contributor graph is built from the git author field only and omits co-author trailers. This credit is real and verifiable in the merged commit, though it will not show as a contributor avatar.
- Two earlier utility-mode PRs were closed as architectural mismatches with the repo's thin-trigger pattern.

### Under review

<!-- OSS-TABLE:START -->
| Repo | Stars | PR | What it fixes |
|---|---|---|---|
| [nilearn/nilearn](https://github.com/nilearn/nilearn) | 1.5k | [#6775](https://github.com/nilearn/nilearn/pull/6775) | [FIX] first_level_from_bids: warn when requested scrub is silently discarded |
| [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) | 213 | [#94](https://github.com/neuralinkcorp/datarepo/pull/94) | Cast date/datetime filter values explicitly for ClickHouseTable |
| [NVIDIA/NemoClaw](https://github.com/NVIDIA/NemoClaw) | 23.1k | [#14832](https://github.com/NVIDIA/NemoClaw/pull/14832) | Fix codebase-growth-guardrails beforeAll hook timeout |
| [scverse/anndata](https://github.com/scverse/anndata) | 787 | [#2761](https://github.com/scverse/anndata/pull/2761) | Fix intermittent test_dask_view_mem memory-ceiling failures on hatch-test.min |
| [NVIDIA-NeMo/Nemotron](https://github.com/NVIDIA-NeMo/Nemotron) | 2.4k | [#401](https://github.com/NVIDIA-NeMo/Nemotron/pull/401) | Isolate non-default config artifacts in nano3/super3/ultra3/omni3 data prep |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.5k | [#1559](https://github.com/TorchIO-project/torchio/pull/1559) | Fix SequentialLabels computing remapping from only the first batch sample |
| [NVIDIA-BioNeMo/nvMolKit](https://github.com/NVIDIA-BioNeMo/nvMolKit) | 286 | [#454](https://github.com/NVIDIA-BioNeMo/nvMolKit/pull/454) | Fix Device3DResult.dense() sizing max_confs from counts instead of conf_index range |
| [MRtrix3/mrtrix3](https://github.com/MRtrix3/mrtrix3) | 359 | [#3467](https://github.com/MRtrix3/mrtrix3/pull/3467) | tckgen -algorithm Tensor_Det/Tensor_Prob: Fix inverted -seed_direction check |
| [Imbad0202/experiment-agent](https://github.com/Imbad0202/experiment-agent) | 221 | [#12](https://github.com/Imbad0202/experiment-agent/pull/12) | Match study_manager_agent.md's participant-data wording to SKILL.md (#11 item 2) |
| [google-research/timesfm](https://github.com/google-research/timesfm) | 35.7k | [#579](https://github.com/google-research/timesfm/pull/579) | Fix MLX signed_log giving zero gradient at x == 0 |
| [google-research/dream-rsi](https://github.com/google-research/dream-rsi) | 98 | [#1](https://github.com/google-research/dream-rsi/pull/1) | Fix CodexAgent leaving orphaned subprocesses on timeout/shutdown |
| [udgamlabs/laghu](https://github.com/udgamlabs/laghu) | 1 | [#2](https://github.com/udgamlabs/laghu/pull/2) | RESULTS.md: note the ctx32k contamination-check bug predates this run |
| [udgamlabs/lilavati](https://github.com/udgamlabs/lilavati) | 0 | [#3](https://github.com/udgamlabs/lilavati/pull/3) | README: note the try/except sandbox fix affects published GSM8K numbers |
| [opencv/opencv](https://github.com/opencv/opencv) | 91.8k | [#30884](https://github.com/opencv/opencv/pull/30884) | Fix segfault in masked float32 minMaxIdx/norm (IPP buffer over-read) |
| [NVIDIA/auto-ontology](https://github.com/NVIDIA/auto-ontology) | 15.5k | [#537](https://github.com/NVIDIA/auto-ontology/pull/537) | Cap _short_table_block's columns like _shown_columns does |
| [timeseriesAI/tsai](https://github.com/timeseriesAI/tsai) | 6.2k | [#990](https://github.com/timeseriesAI/tsai/pull/990) | Fix TSNormalize(by_sample=True) corrupting variables excluded from a listy by_var |
| [CamDavidsonPilon/lifelines](https://github.com/CamDavidsonPilon/lifelines) | 2.6k | [#1721](https://github.com/CamDavidsonPilon/lifelines/pull/1721) | Fix swapped lower/upper confidence interval columns in BreslowFlemingHarringtonFitter |
| [fooof-tools/fooof](https://github.com/fooof-tools/fooof) | 456 | [#413](https://github.com/fooof-tools/fooof/pull/413) | Fix get_group(None, ...) producing wrong-shaped/empty event_time_results |
| [neurodsp-tools/neurodsp](https://github.com/neurodsp-tools/neurodsp) | 361 | [#371](https://github.com/neurodsp-tools/neurodsp/pull/371) | Fix off-by-one sample shift in burst-duration filtering |
| [pactools/pactools](https://github.com/pactools/pactools) | 109 | [#42](https://github.com/pactools/pactools/pull/42) | Reject bandpass centers at or above Nyquist, fix auto grid endpoint |
| [google-deepmind/alphagenome](https://github.com/google-deepmind/alphagenome) | 2.3k | [#62](https://github.com/google-deepmind/alphagenome/pull/62) | Fix Interval.resize(None) raising TypeError instead of a no-op |
| [MRtrix3/mrtrix3](https://github.com/MRtrix3/mrtrix3) | 359 | [#3462](https://github.com/MRtrix3/mrtrix3/pull/3462) | mrmath: fix median operation not ignoring infinite values |
| [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) | 213 | [#87](https://github.com/neuralinkcorp/datarepo/pull/87) | Accept ISO date/datetime strings in ParquetTable filters |
| [NVIDIA/Model-Optimizer](https://github.com/NVIDIA/Model-Optimizer) | 5.7k | [#3291](https://github.com/NVIDIA/Model-Optimizer/pull/3291) | fix(quantization): pad MXFP4QTensor blocks like its sibling QTensor types |
| [Project-MONAI/MONAI](https://github.com/Project-MONAI/MONAI) | 8.9k | [#9268](https://github.com/Project-MONAI/MONAI/pull/9268) | fix(metrics): SurfaceDistanceMetric leaks inf for ignore_index channel |
| [wheresryan22/anatomy](https://github.com/wheresryan22/anatomy) | 29.5k | [#150](https://github.com/wheresryan22/anatomy/pull/150) | print.mjs: also look in the Windows Playwright cache for Chrome |
| [google-deepmind/neural_testbed](https://github.com/google-deepmind/neural_testbed) | 192 | [#9](https://github.com/google-deepmind/neural_testbed/pull/9) | Fix correlated PRNG keys in GaussianSampleKL.kl_estimate |
| [google-deepmind/alphagenome_research](https://github.com/google-deepmind/alphagenome_research) | 939 | [#30](https://github.com/google-deepmind/alphagenome_research/pull/30) | Mask opposite-strand tracks in GeneIntervalScorer.finalize_interval |
| [ANTsX/ANTsPy](https://github.com/ANTsX/ANTsPy) | 893 | [#957](https://github.com/ANTsX/ANTsPy/pull/957) | Preserve channels_first through resample_image, smooth_image, and indexing |
| [Lightning-AI/pytorch-lightning](https://github.com/Lightning-AI/pytorch-lightning) | 31.5k | [#22145](https://github.com/Lightning-AI/pytorch-lightning/pull/22145) | Fix step-interval scheduler frequency under gradient accumulation |
| [Project-MONAI/MONAILabel](https://github.com/Project-MONAI/MONAILabel) | 918 | [#1939](https://github.com/Project-MONAI/MONAILabel/pull/1939) | Set display color on the highdicom DICOM-SEG export path |
| [udgamlabs/udgam-english-125m](https://github.com/udgamlabs/udgam-english-125m) | 0 | [#1](https://github.com/udgamlabs/udgam-english-125m/pull/1) | Re-check committed shard hashes on resume in repaired packer |
| [udgamlabs/shruti](https://github.com/udgamlabs/shruti) | 13 | [#2](https://github.com/udgamlabs/shruti/pull/2) | onnx: don't drop the trailing partial VAD window |
| [scverse/anndata](https://github.com/scverse/anndata) | 787 | [#2737](https://github.com/scverse/anndata/pull/2737) | Fix Reindexer._apply_to_dask_array densifying a sparse zero-axis input |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.5k | [#1549](https://github.com/TorchIO-project/torchio/pull/1549) | Fix EnsureShapeMultiple computing target shape from the wrong image |
| [MRtrix3/mrtrix3](https://github.com/MRtrix3/mrtrix3) | 359 | [#3457](https://github.com/MRtrix3/mrtrix3/pull/3457) | Fix get_iqr() reading the wrong index for the lower quartile |
| [RikiyaT/lm_understand-logs](https://github.com/RikiyaT/lm_understand-logs) | 1.3k | [#10](https://github.com/RikiyaT/lm_understand-logs/pull/10) | Fix acc_lenient always null for non-sharded eval runs in merge.py |
| [NVIDIA-BioNeMo/cuik-molmaker](https://github.com/NVIDIA-BioNeMo/cuik-molmaker) | 38 | [#8](https://github.com/NVIDIA-BioNeMo/cuik-molmaker/pull/8) | Fix self-loop zero-fill writing to the wrong location and size |
| [NVIDIA-BioNeMo/RNAPro](https://github.com/NVIDIA-BioNeMo/RNAPro) | 103 | [#7](https://github.com/NVIDIA-BioNeMo/RNAPro/pull/7) | Fix get_prot_nuc_frame checking only the first frame atom |
| [NVIDIA-BioNeMo/megalodon](https://github.com/NVIDIA-BioNeMo/megalodon) | 26 | [#2](https://github.com/NVIDIA-BioNeMo/megalodon/pull/2) | Fix double-indexing of batch in discrete_fm interpolate_edges |
| [NVIDIA-BioNeMo/warpKAN](https://github.com/NVIDIA-BioNeMo/warpKAN) | 4 | [#1](https://github.com/NVIDIA-BioNeMo/warpKAN/pull/1) | Fix order-3/4 backward B-spline kernels excluding left grid boundary |
| [NVIDIA-BioNeMo/bionemo-agent-toolkit](https://github.com/NVIDIA-BioNeMo/bionemo-agent-toolkit) | 514 | [#61](https://github.com/NVIDIA-BioNeMo/bionemo-agent-toolkit/pull/61) | Fix ColabFold MSA script dropping selenomethionine (MSE) residues |
| [udgamlabs/udgam-evals](https://github.com/udgamlabs/udgam-evals) | 0 | [#1](https://github.com/udgamlabs/udgam-evals/pull/1) | Make g_units level 3 use the sampled unit pair, not a hardcoded one |
| [NVIDIA/NemoClaw](https://github.com/NVIDIA/NemoClaw) | 23.1k | [#13925](https://github.com/NVIDIA/NemoClaw/pull/13925) | Enforce Hermes's 64k Ollama context-window floor on inference set, no… |
| [NVIDIA/DeepLearningExamples](https://github.com/NVIDIA/DeepLearningExamples) | 14.9k | [#1470](https://github.com/NVIDIA/DeepLearningExamples/pull/1470) | Fix BERT pretraining periodic loss logging to average across all ranks |
| [NVIDIA/Megatron-LM](https://github.com/NVIDIA/Megatron-LM) | 18.6k | [#8649](https://github.com/NVIDIA/Megatron-LM/pull/8649) | Fix AbsorbedMLA to respect explicit config.softmax_scale override |
| [NVIDIA/TensorRT](https://github.com/NVIDIA/TensorRT) | 13.5k | [#4900](https://github.com/NVIDIA/TensorRT/pull/4900) | Resolve negative axis in ScatterElements plugin before indexing Dims |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | 58.8k | [#1020](https://github.com/Imbad0202/academic-research-skills/pull/1020) | fix(socratic): scope three unscoped rules to goal-oriented mode (#991) |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.5k | [#1541](https://github.com/TorchIO-project/torchio/pull/1541) | Fix Crop/CropOrPad silently leaving a fully-cropped axis uncropped |
| [MRtrix3/mrtrix3](https://github.com/MRtrix3/mrtrix3) | 359 | [#3454](https://github.com/MRtrix3/mrtrix3/pull/3454) | algo/histogram: fix Data::bin() silently dropping the maximum value |
| [NVIDIA/Deep-Learning-Accelerator-SW](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW) | 242 | [#42](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW/pull/42) | Cast scale to float in save_scales to keep it JSON-serializable |
| [Proximal-Labs/frontier-swe](https://github.com/Proximal-Labs/frontier-swe) | 239 | [#88](https://github.com/Proximal-Labs/frontier-swe/pull/88) | dart-style-haskell: fix instruction.md reference to nonexistent test dir |
| [Proximal-Labs/frontier-swe](https://github.com/Proximal-Labs/frontier-swe) | 239 | [#87](https://github.com/Proximal-Labs/frontier-swe/pull/87) | Mount persisted trial-state volume at sandbox startup |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.5k | [#1527](https://github.com/TorchIO-project/torchio/pull/1527) | Fix include/exclude being silently ignored in 9 remaining transforms |
| [NVIDIA/Deep-Learning-Accelerator-SW](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW) | 242 | [#40](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW/pull/40) | Fix bias-less Conv handling in fuse_convs_horizontally |
| [NVIDIA/Deep-Learning-Accelerator-SW](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW) | 242 | [#38](https://github.com/NVIDIA/Deep-Learning-Accelerator-SW/pull/38) | Replace removed np.product with np.prod |
| [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio) | 2.5k | [#1518](https://github.com/TorchIO-project/torchio/pull/1518) | Compute normalization statistics per sample |
| [scverse/anndata](https://github.com/scverse/anndata) | 787 | [#2517](https://github.com/scverse/anndata/pull/2517) | test(backed): add regression for filename=None after read_h5ad |
<!-- OSS-TABLE:END -->

### Organizations

Owners of the repos above where a PR has merged, tagged rather than named.

<!-- OSS-ORGS:START -->
**23 organizations, 32 repos.**

<p><a href="https://github.com/Imbad0202" title="Imbad0202"><img src="https://github.com/Imbad0202.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="Imbad0202"/></a> <a href="https://github.com/InsightSoftwareConsortium" title="InsightSoftwareConsortium"><img src="https://github.com/InsightSoftwareConsortium.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="InsightSoftwareConsortium"/></a> <a href="https://github.com/MRtrix3" title="MRtrix3"><img src="https://github.com/MRtrix3.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="MRtrix3"/></a> <a href="https://github.com/MakazhanAlpamys" title="MakazhanAlpamys"><img src="https://github.com/MakazhanAlpamys.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="MakazhanAlpamys"/></a> <a href="https://github.com/NVIDIA" title="NVIDIA"><img src="https://github.com/NVIDIA.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="NVIDIA"/></a> <a href="https://github.com/NeuroTechX" title="NeuroTechX"><img src="https://github.com/NeuroTechX.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="NeuroTechX"/></a> <a href="https://github.com/Project-MONAI" title="Project-MONAI"><img src="https://github.com/Project-MONAI.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="Project-MONAI"/></a> <a href="https://github.com/SpikeInterface" title="SpikeInterface"><img src="https://github.com/SpikeInterface.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="SpikeInterface"/></a> <a href="https://github.com/alphaXiv" title="alphaXiv"><img src="https://github.com/alphaXiv.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="alphaXiv"/></a> <a href="https://github.com/galaxyproject" title="galaxyproject"><img src="https://github.com/galaxyproject.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="galaxyproject"/></a> <a href="https://github.com/google" title="google"><img src="https://github.com/google.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="google"/></a> <a href="https://github.com/jordan-gibbs" title="jordan-gibbs"><img src="https://github.com/jordan-gibbs.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="jordan-gibbs"/></a> <a href="https://github.com/keras-team" title="keras-team"><img src="https://github.com/keras-team.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="keras-team"/></a> <a href="https://github.com/neuralinkcorp" title="neuralinkcorp"><img src="https://github.com/neuralinkcorp.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="neuralinkcorp"/></a> <a href="https://github.com/neuropsychology" title="neuropsychology"><img src="https://github.com/neuropsychology.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="neuropsychology"/></a> <a href="https://github.com/nilearn" title="nilearn"><img src="https://github.com/nilearn.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="nilearn"/></a> <a href="https://github.com/nipy" title="nipy"><img src="https://github.com/nipy.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="nipy"/></a> <a href="https://github.com/pydicom" title="pydicom"><img src="https://github.com/pydicom.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="pydicom"/></a> <a href="https://github.com/scverse" title="scverse"><img src="https://github.com/scverse.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="scverse"/></a> <a href="https://github.com/sunlabuiuc" title="sunlabuiuc"><img src="https://github.com/sunlabuiuc.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="sunlabuiuc"/></a> <a href="https://github.com/udgamlabs" title="udgamlabs"><img src="https://github.com/udgamlabs.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="udgamlabs"/></a> <a href="https://github.com/unstablebuild" title="unstablebuild"><img src="https://github.com/unstablebuild.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="unstablebuild"/></a> <a href="https://github.com/wheresryan22" title="wheresryan22"><img src="https://github.com/wheresryan22.png" width="44" height="44" style="border-radius:50%;margin:0 4px" alt="wheresryan22"/></a> </p>
<!-- OSS-ORGS:END -->

## Contact

- Email: sn3199@columbia.edu
- LinkedIn: https://www.linkedin.com/in/nanda-siddhardha/
- Medium: https://medium.com/@nandasiddhardha
- ResearchGate: https://researchgate.net/profile/Nanda-Siddhardha

---

<!-- CUMULATIVE-STARS:START -->
**234.6k combined stars** across the 32 repos above (sum of each repo's current count, not a dedup of my own contribution).
<!-- CUMULATIVE-STARS:END -->

<!-- LAST-UPDATED:START -->
This page refreshes automatically every day around 13:00 UTC (1:00 PM UTC) via GitHub Actions. Last run: 2026-11-27 21:42 UTC.
<!-- LAST-UPDATED:END -->
