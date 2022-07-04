<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-table-dialog-box">
        <div class="meedu-table-dialog-header">
          <span>{{ text }}</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="meedu-table-dialog-body">
          <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="list"
            class="float-left"
          >
            <el-table-column label="课时名称" min-width="32%">
              <template slot-scope="scope">
                <template>
                  <template v-if="videos[scope.row.video_id]">
                    <span>{{ videos[scope.row.video_id].title }}</span>
                  </template>
                  <span v-else class="c-red">课时不存在</span>
                </template>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="课时时长"
              min-width="13%"
              ><template slot-scope="scope">
                <duration-text
                  v-if="!loading"
                  :duration="scope.row.watch_seconds"
                ></duration-text>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="已学时长"
              min-width="13%"
              ><template slot-scope="scope">
                <duration-text
                  v-if="!loading"
                  :duration="scope.row.watch_seconds"
                ></duration-text>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="是否学完" min-width="10%">
              <template slot-scope="scope">
                <span class="c-green" v-if="scope.row.watched_at">已学完</span>
                <span v-else>未学完</span>
              </template>
            </el-table-column>
            <el-table-column label="开始学习时间" min-width="16%">
              <template slot-scope="scope">
                <span v-if="scope.row.created_at">{{
                  scope.row.created_at | dateFormat
                }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="最近一次学习" min-width="16%">
              <template slot-scope="scope">
                <span v-if="scope.row.watched_at">{{
                  scope.row.watched_at | dateFormat
                }}</span>
                <span v-else>-</span>
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
  props: ["id", "text", "userId"],
  data() {
    return {
      pagination: {
        page: 1,
        size: 10000,
      },
      loading: false,
      list: [],
      total: 0,
      videos: [],
    };
  },
  mounted() {
    if (this.id) {
      this.getData();
    }
  },
  methods: {
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination, {
        cid: this.id,
      });
      this.$api.Member.UserVideoWatchRecords(this.userId, params).then(
        (res) => {
          this.loading = false;
          this.list = res.data.data.data;
          this.total = res.data.data.total;
          this.videos = res.data.videos;
        }
      );
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
