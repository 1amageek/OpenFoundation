#ifndef C_OPEN_FOUNDATION_EMBEDDED_FILE_SYSTEM_H
#define C_OPEN_FOUNDATION_EMBEDDED_FILE_SYSTEM_H

#include <stddef.h>
#include <stdint.h>

int32_t open_foundation_read_file(
    const char *path,
    uint8_t **output_bytes,
    size_t *output_count
);
int32_t open_foundation_write_file(
    const char *path,
    const uint8_t *bytes,
    size_t count
);
void open_foundation_release_bytes(void *bytes);

#endif
