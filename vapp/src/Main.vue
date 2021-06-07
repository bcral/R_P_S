<template>
  <div v-if="isDrizzleInitialized">
    <p>
      <drizzle-contract
        contractName="ComplexStorage"
        method="string1"
        label="bytes string1"
        toUtf8
      />
    </p>
  </div>

  <div v-else>Loading...</div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'ComplexStorage',
  computed: {


  },
  data() {
    return {

    }
  }
}
</script>

<style scoped>

</style>
