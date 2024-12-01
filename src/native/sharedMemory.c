#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct {
    void *memory;
    size_t size;
} SharedMemory;

SharedMemory *create_shared_memory(size_t size) {
    SharedMemory *buffer = (SharedMemory *)malloc(sizeof(SharedMemory));
    if (buffer == NULL) {
        perror("Failed to allocate SharedMemory");
        return NULL;
    }

    buffer->memory = malloc(size);
    if (buffer->memory == NULL) {
        free(buffer);
        perror("Failed to allocate memory buffer");
        return NULL;
    }
    buffer->size = size;
    memset(buffer->memory, 0, size);

    return buffer;
}

void clear_shared_memory(SharedMemory *buffer) {
    if (buffer != NULL) {
        if (buffer->memory != NULL) {
            free(buffer->memory);
        }
        free(buffer);
    }
}
