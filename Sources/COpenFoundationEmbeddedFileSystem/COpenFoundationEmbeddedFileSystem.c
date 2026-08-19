#include "COpenFoundationEmbeddedFileSystem.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

int32_t open_foundation_read_file(
    const char *path,
    uint8_t **output_bytes,
    size_t *output_count
) {
    if (path == NULL || output_bytes == NULL || output_count == NULL) {
        return EINVAL;
    }

    *output_bytes = NULL;
    *output_count = 0;

    FILE *file = fopen(path, "rb");
    if (file == NULL) {
        return errno == 0 ? EIO : errno;
    }

    if (fseek(file, 0, SEEK_END) != 0) {
        int32_t error_code = errno == 0 ? EIO : errno;
        fclose(file);
        return error_code;
    }

    long file_length = ftell(file);
    if (file_length < 0) {
        int32_t error_code = errno == 0 ? EIO : errno;
        fclose(file);
        return error_code;
    }

    if (fseek(file, 0, SEEK_SET) != 0) {
        int32_t error_code = errno == 0 ? EIO : errno;
        fclose(file);
        return error_code;
    }

    if (file_length == 0) {
        if (fclose(file) != 0) {
            return errno == 0 ? EIO : errno;
        }
        return 0;
    }

    size_t byte_count = (size_t)file_length;
    uint8_t *bytes = malloc(byte_count);
    if (bytes == NULL) {
        fclose(file);
        return ENOMEM;
    }

    size_t read_count = fread(bytes, 1, byte_count, file);
    if (read_count != byte_count) {
        int32_t error_code = ferror(file) && errno != 0 ? errno : EIO;
        free(bytes);
        fclose(file);
        return error_code;
    }

    if (fclose(file) != 0) {
        int32_t error_code = errno == 0 ? EIO : errno;
        free(bytes);
        return error_code;
    }

    *output_bytes = bytes;
    *output_count = byte_count;
    return 0;
}

int32_t open_foundation_write_file(
    const char *path,
    const uint8_t *bytes,
    size_t count
) {
    if (path == NULL || (bytes == NULL && count != 0)) {
        return EINVAL;
    }

    FILE *file = fopen(path, "wb");
    if (file == NULL) {
        return errno == 0 ? EIO : errno;
    }

    if (count != 0 && fwrite(bytes, 1, count, file) != count) {
        int32_t error_code = errno == 0 ? EIO : errno;
        fclose(file);
        return error_code;
    }

    if (fclose(file) != 0) {
        return errno == 0 ? EIO : errno;
    }

    return 0;
}

void open_foundation_release_bytes(void *bytes) {
    free(bytes);
}
