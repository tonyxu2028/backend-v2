<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-table-dialog-box">
        <div class="meedu-table-dialog-header">
          <span>学习进度</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="meedu-table-dialog-body" v-loading="loading">
          <el-table
            :data="list"
            class="float-left"
            row-key="id"
            :tree-props="{ children: 'children' }"
            v-loading="loading"
          >
            <el-table-column prop="video_title" label="标题"> </el-table-column>
            <el-table-column label="进度" width="300">
              <template slot-scope="scope">
                <div>
                  <duration-text
                    v-if="scope.row.watch_seconds > 0"
                    :duration="scope.row.watch_seconds"
                  ></duration-text>
                  <span v-else>0:00</span>
                  /
                  <duration-text :duration="scope.row.duration"></duration-text>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="url" label="状态" width="120">
              <template slot-scope="scope">
                <span class="c-green" v-if="scope.row.watch_seconds >= scope.row.duration">
                  已学完
                </span>
                <span v-else>未学完</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import DurationText from "@/components/duration-text";

export default {
  components: {
    DurationText,
  },
  props: ["cid", "uid"],
  data() {
    return {
      list: [],
      loading: false,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Course.Vod.Records.Detail(this.cid, this.uid).then((res) => {
        this.loading = false;
        this.list = res.data.data;
      });
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
