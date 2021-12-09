
void wrapper_randomx_init(int32_t id, uint8_t* key, int32_t length);

int32_t wrapper_randomx_size_of_hash();

void wrapper_randomx_hash(int32_t id, uint8_t* bytes, int32_t length, uint8_t* out);

void wrapper_randomx_destroy(int32_t id);

