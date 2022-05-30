<template>
  <el-link
    :href="href"
    :underline="underline"
    :disabled="disabled"
    :target="target"
    :type="type"
    :icon="icon"
    @click="$emit('click')"
    v-if="through || multiThrough"
    >{{ text }}</el-link
  >
</template>

<script>
import { mapState } from "vuex";

export default {
  props: [
    "href",
    "target",
    "type",
    "underline",
    "disabled",
    "icon",
    "p",
    "text",
    "pBox",
  ],
  computed: {
    ...mapState(["user"]),
    through() {
      if (!this.user) {
        return false;
      }

      return typeof this.user.permissions[this.p] !== "undefined";
    },
    multiThrough() {
      if (!this.user) {
        return false;
      }
      let key = false;
      if (this.pBox) {
        for (let i = 0; i < this.pBox.length; i++) {
          if (typeof this.user.permissions[this.pBox[i]] !== "undefined") {
            key = true;
          }
        }
      }
      return key;
    },
  },
};
</script>
