# Performance Optimization Guide

## Current Optimizations Applied:

### 1. **ansible.cfg Optimizations**
- **Smart gathering**: Only gathers facts when needed
- **Fact caching**: Caches facts for 1 hour to avoid re-gathering
- **SSH connection reuse**: Maintains persistent connections for 5 minutes
- **Pipelining**: Reduces SSH connections by combining operations
- **Increased forks**: Runs up to 10 parallel processes
- **Profiling enabled**: Shows task execution times

### 2. **Playbook Structure Optimizations**
- **Strategy: linear**: Ensures predictable execution order
- **Serial: 1**: Processes one host at a time (good for workstation setup)
- **Tags**: Allow selective execution of specific components
- **OS-specific facts**: Pre-calculated for faster conditionals

### 3. **Task Optimizations**
- **include_tasks**: Faster than import_tasks for conditional loading
- **Retry settings**: Global retry configuration for network operations
- **Default values**: Prevent undefined variable errors

## Usage Examples:

### Run only macOS tasks:
```bash
ansible-playbook main.yml -i inventory/hosts --tags macos
```

### Run only package installation:
```bash
ansible-playbook main.yml -i inventory/hosts --tags linux
```

### Skip dotfiles:
```bash
ansible-playbook main.yml -i inventory/hosts --skip-tags dotfiles
```

### Profile task execution times:
```bash
ANSIBLE_CALLBACK_WHITELIST=timer,profile_tasks ansible-playbook main.yml -i inventory/hosts
```

## Additional Recommendations:

### 4. **For Large Package Lists**
Consider using package managers' native batch operations:
- Use `homebrew` module with lists instead of loops
- Use `dnf`/`apt` with package lists instead of individual installs

### 5. **Async Operations**
For long-running tasks (like large downloads), use:
```yaml
async: 300
poll: 10
```

### 6. **Conditional Optimization**
Use `when` clauses early to skip expensive operations:
```yaml
when: 
  - configure_feature | default(false)
  - ansible_os_family == "Darwin"
```

### 7. **Error Handling**
Add retry logic for network operations:
```yaml
retries: "{{ retry_count | default(3) }}"
delay: "{{ retry_delay | default(5) }}"
```
