#!/bin/bash

set -e

REGION_DIR=""
KEEP_REGIONS=3
DRY_RUN=false
LOG_FILE=""

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Prune Minecraft End dimension chunks beyond specified radius from spawn.

Options:
    -d, --dir PATH       Path to End dimension region directory (required)
                         Old MC (pre-26.1): /path/to/world/DIM1/region
                         New MC (26.1+):    /path/to/world/dimensions/minecraft/the_end/region
    -r, --radius REGIONS Keep region files within this radius (default: 3 = 7x7 grid = ~3500x3500 blocks)
    -n, --dry-run        Show what would be deleted without deleting
    -l, --log FILE       Log actions to file
    -h, --help           Show this help

Examples:
    # Old Minecraft structure (pre-26.1)
    $0 -d /path/to/world/DIM1/region -r 3
    
    # New Minecraft structure (26.1+)
    $0 -d /path/to/world/dimensions/minecraft/the_end/region -r 3
    
    # Dry run to preview
    $0 -d /path/to/world/dimensions/minecraft/the_end/region --dry-run
EOF
    exit 1
}

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    if [[ -n "$LOG_FILE" ]]; then
        echo "$msg" >> "$LOG_FILE"
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir) REGION_DIR="$2"; shift 2 ;;
        -r|--radius) KEEP_REGIONS="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -l|--log) LOG_FILE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [[ -z "$REGION_DIR" ]]; then
    echo "Error: Region directory is required"
    usage
fi

if [[ ! -d "$REGION_DIR" ]]; then
    log "ERROR: Directory not found: $REGION_DIR"
    exit 1
fi

if ! [[ "$KEEP_REGIONS" =~ ^[0-9]+$ ]]; then
    log "ERROR: Radius must be a positive integer"
    exit 1
fi

keep_range=$((KEEP_REGIONS * 2 + 1))
keep_blocks=$((keep_range * 512))
log "Starting prune operation"
log "Region directory: $REGION_DIR"
log "Keep radius: $KEEP_REGIONS regions ($keep_range x $keep_range grid = ~$keep_blocks x $keep_blocks blocks)"
log "Dry run: $DRY_RUN"

deleted=0
kept=0
errors=0

for file in "$REGION_DIR"/r.*.*.mca; do
    [[ -e "$file" ]] || continue
    
    filename=$(basename "$file")
    
    if [[ ! "$filename" =~ ^r\.(-?[0-9]+)\.(-?[0-9]+)\.mca$ ]]; then
        log "WARNING: Skipping non-region file: $filename"
        continue
    fi
    
    x="${BASH_REMATCH[1]}"
    z="${BASH_REMATCH[2]}"
    
    if (( x >= -KEEP_REGIONS && x <= KEEP_REGIONS && z >= -KEEP_REGIONS && z <= KEEP_REGIONS )); then
        kept=$((kept + 1))
        continue
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would delete: $filename"
    else
        if rm "$file" 2>/dev/null; then
            log "Deleted: $filename"
            deleted=$((deleted + 1))
        else
            log "ERROR: Failed to delete: $filename"
            errors=$((errors + 1))
        fi
    fi
done

log "Summary: kept=$kept, deleted=$deleted, errors=$errors"

if [[ "$DRY_RUN" == true ]]; then
    log "Dry run complete - no files were actually deleted"
else
    log "Prune operation completed successfully"
fi
