# Linux Hardening Toolkit

A modular Bash-based toolkit to apply basic security hardening on fresh Linux systems.

## Features

- Multi-distro support:
    - Arch-based
    - Debian-based
    - RHEL-based
- Modular architecture
- Dry-run mode (safe simulation)
- Configurable via external file
- Profile support (`server`, `desktop`)

## Modules

- System updates
- SSH hardening
- Firewall configuration (UFW / firewalld)
- Kernel hardening (sysctl)
- Service minimization

## Usage

```bash
./hardening.sh --dry-run
```

### Dry-run (no changes applied)

```bash
./hardening.sh --dry-run
```

### Run specific module

```bash
./hardening.sh --only ssh
```

### Disable modules

```bash
./hardening.sh --no-firewall --no-services
```

## Configuration

Edit:

```bash
configs/default.conf
```

Example:

```bash
PROFILE=server
ENABLE_FIREWALL=true
ENABLE_SERVICES=true
```

## Project structure

```bash
linux-hardening-toolkit/
├─ hardening.sh
├─ modules/
├─ configs/
├─ logs/
├─ docs/
```

## Disclaimer

This tool applies basic hardening measures.
Always review configurations before using in production environments.

## License

MIT
