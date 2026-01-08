# Contributing

Thank you for your interest in contributing to this project!

## Testing Workflows Locally

While you can't run GitHub Actions locally, you can test the build scripts:

```bash
# Test the complete build process
./01-checkout.sh
./02-download-tbb.sh
./03-configure-minsizerel.sh
./04-build-minsizerel.sh
./05-setup-env-minsizerel.sh

# Verify the build
source dist-minsizerel-ms/setup-usd-env.sh
usdcat --help
```

## Modifying Workflows

When modifying workflows:

1. **Test build scripts locally first** - Ensure scripts work before updating workflows
2. **Use act for local testing** (optional) - Install [act](https://github.com/nektos/act) to test workflows locally
3. **Check YAML syntax** - Use a YAML linter before committing
4. **Test on a fork** - Push to your fork to test workflows before submitting PR

## Build Script Guidelines

- Keep scripts POSIX-compliant where possible
- Include clear error messages
- Validate prerequisites before building
- Use `set -e` to fail fast on errors
- Document non-obvious steps

## Workflow Guidelines

- Pin action versions (e.g., `@v4`, not `@latest`)
- Add clear step names
- Include verification steps
- Set appropriate artifact retention
- Document trigger conditions

## Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Test your changes locally
4. Update documentation if needed
5. Submit a pull request with clear description

## Questions?

Open an issue for:
- Build failures
- Feature requests
- Documentation improvements
- Bug reports
