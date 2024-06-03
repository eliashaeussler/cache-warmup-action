<div align="center">

# Cache Warmup GitHub Action

[![CGL](https://img.shields.io/github/actions/workflow/status/eliashaeussler/cache-warmup-action/cgl.yaml?label=cgl&logo=github)](https://github.com/eliashaeussler/cache-warmup-action/actions/workflows/cgl.yaml)
[![Tests](https://img.shields.io/github/actions/workflow/status/eliashaeussler/cache-warmup-action/tests.yaml?label=tests&logo=github)](https://github.com/eliashaeussler/cache-warmup-action/actions/workflows/tests.yaml)
[![Latest version](https://img.shields.io/github/v/tag/eliashaeussler/cache-warmup-action?sort=semver&filter=v*&logo=github&label=latest)](https://github.com/eliashaeussler/cache-warmup-action/releases/latest)

</div>

GitHub Action for [`eliashaeussler/cache-warmup`](https://github.com/eliashaeussler/cache-warmup),
a library to warm up website caches of URLs located in XML sitemaps.
Read more in the [official documentation](https://cache-warmup.dev/).

## 🔥 Usage

> [!IMPORTANT]
> The action requires at least version **0.7.0** of the
> `eliashaeussler/cache-warmup` library.

Create a new workflow or add a new step to your existing workflow:

```yaml
# .github/workflows/cache-warmup.yaml

name: Cache Warmup
on:
  push:
    tags:
      - '*'

jobs:
  cache-warmup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up environment
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.3
          coverage: none

      - name: Run cache warmup
        uses: eliashaeussler/cache-warmup-action@v1
        with:
          version: latest
          sitemaps: |
            https://www.example.com/sitemap.xml
            https://www.example.com/de/sitemap.xml
          urls: |
            https://www.example.com/another-url
          limit: 250
          progress: true
          verbosity: vvv
          config: cache-warmup.json
```

## 📝 Inputs

The following inputs are currently available:

| Name        | Description                                                                                              | Default  | Required |
|-------------|----------------------------------------------------------------------------------------------------------|----------|----------|
| `version`   | Version of the `eliashaeussler/cache-warmup` library to use (must be at least `0.7.0`)                   | `latest` | ✅        |
| `sitemaps`  | URLs or local filenames of XML sitemaps to be warmed up, separated by newline                            | –        | –        |
| `urls`      | Additional URLs to be warmed up, separated by newline                                                    | –        | –        |
| `limit`     | Limit the number of URLs to be processed                                                                 | `0`      | –        |
| `progress`  | Show a progress bar during cache warmup                                                                  | –        | –        |
| `verbosity` | Increase output verbosity (`v`, `vv` or `vvv`)                                                           | –        | –        |
| `config`    | Path to an external configuration file (supported since v3 of the `eliashaeussler/cache-warmup` library) | –        | –        |

## 💬 Outputs

The following outputs are currently generated:

| Name      | Description                                               |
|-----------|-----------------------------------------------------------|
| `version` | Used version of the `eliashaeussler/cache-warmup` library |

## ⭐ License

This project is licensed under [GNU General Public License 3.0 (or later)](LICENSE.md).
