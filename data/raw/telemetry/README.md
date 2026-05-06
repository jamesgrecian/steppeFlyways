# Telemetry data

*How to set up Movebank access. The `data/` folder is gitignored — no data files are committed to this repository.*
  
  ## Source — Movebank
  
  Telemetry data is held on [Movebank](https://www.movebank.org) and pulled into R via the `move2` package. Access requires three things:
  
  1. A free Movebank account
2. Permission from each study owner (added by them as a collaborator on the study)
3. Acceptance of each study's licence terms (one-off, via the Movebank web UI)

### One-time setup: store credentials in the system keyring

Credentials are stored in the OS-level keyring (macOS Keychain, Windows Credential Manager, Linux libsecret) — *not* in plaintext on disk. Run this once per machine, in the R console (not in a script):

```r
install.packages(c("move2", "keyring"))

library(move2)
movebank_store_credentials("your_movebank_username", "your_password")
```

After that, every `move2` download function pulls credentials from the keyring automatically. To check it worked: `keyring::key_list()` should show a row with `service = "movebank"`.

To update a password: `movebank_store_credentials("user", "newpass", force = TRUE)`. To remove: `movebank_remove_credentials()`.

### Finding relevant studies

`movebank_download_study_info()` returns metadata for every study your account can see. Filter by species of interest:

```r
library(dplyr)
library(purrr)

all_studies <- movebank_download_study_info()

steppe_studies <- all_studies |>
  filter(map_lgl(taxon_ids,
                 ~ isTRUE(any(grepl("Aquila nipalensis", .x, ignore.case = TRUE)))))
```

The `i_have_download_access` column tells you which of those you can actually pull from.

### Per-study licence acceptance

Even with download access, each study requires you to accept its licence terms before the API will release data. **Do this on the Movebank website**, not programmatically — it forces you to read the citation requirements, PI name, and any specific use restrictions:

1. Go to the study page (search by name on movebank.org or follow the DOI from study info)
2. Click through to download
3. Read and accept the licence

This is a one-off per study. The accepted state is bound to your Movebank account.

Worth recording the citation string for each study in `metadata/citations.md` as you accept.

### Pulling data

The pipeline script `../scripts/01_ingest.R` handles the actual download with local caching. Populate the `study_ids` vector in that script with the study IDs and a sensible filename-safe label.

A slim pull (location data only) is much faster than the default:

```r
movebank_download_study(
  study_id       = <study_id>,
  sensor_type_id = "gps",
  attributes     = NULL    # timestamp, location, track id only
)
```

## Governance

- Telemetry data is not redistributed under any circumstances.
- MoU terms govern use, retention, and co-authorship.
- Movebank licence terms must be accepted (and re-read) per study.
- Provenance, citation strings, and pull dates are kept in `metadata/`.

---

*Last updated: April 2026*