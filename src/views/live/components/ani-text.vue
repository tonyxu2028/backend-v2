<template>
  <div
    :style="{
      color: result,
    }"
    v-if="type === 'time'"
  >
    <duration-text :duration="value"></duration-text>
  </div>
  <span
    :style="{
      color: result,
    }"
    v-else
    >{{ value }}</span
  >
</template>

<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
  },
  props: ["value", "total", "type"],
  data() {
    return {
      result: "rgba(255,0,0,0.1)",
    };
  },
  mounted() {
    if (this.total > 0) {
      let opacity = this.value / this.total;
      if (opacity === 0) {
        this.result = "rgba(255,0,0,0.1)";
      } else {
        if (opacity > 0.1) {
          this.result = "rgba(255,0,0," + opacity.toFixed(2) + ")";
        }
      }
    }
  },
};
</script>
