<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="直播课程统计"></back-bar>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="videos"
          @sort-change="sortChange"
          :default-sort="{ prop: '', order: 'descending' }"
          class="float-left"
        >
          <el-table-column prop="title" label="直播课"> </el-table-column>
          <el-table-column
            label="学习人数"
            sortable
            prop="user_count"
            width="200"
          >
            <template slot-scope="scope">
              <span v-if="scope.row.status === 0 || scope.row.status === 1"
                >-</span
              >
              <span v-else>{{ scope.row.user_count }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="聊天消息数"
            sortable
            prop="chat_count"
            width="200"
          >
            <template slot-scope="scope">
              <span v-if="scope.row.status === 0 || scope.row.status === 1"
                >-</span
              >
              <span v-else>{{ scope.row.chat_count }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="直播时长"
            sortable
            prop="real_duration"
            width="200"
          >
            <template slot-scope="scope">
              <span v-if="scope.row.status === 0 || scope.row.status === 1"
                >-</span
              >
              <duration-text v-else :duration="scope.row.real_duration">
              </duration-text>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
  </div>
</template>

<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
  },
  data() {
    return {
      pageName: "liveStats-list",
      pagination: {
        id: null,
        sort: "",
        order: "desc",
      },
      loading: false,
      videos: [],
      max_chat_count: 0,
      max_duration: 0,
      max_user_count: 0,
    };
  },
  activated() {
    this.getData();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      this.pagination.id = this.$route.query.id;
      Object.assign(params, this.pagination);
      this.$api.Course.Live.Course.Stats(this.pagination.id, params).then(
        (res) => {
          this.max_chat_count = res.data.max_chat_count;
          this.max_duration = res.data.max_duration;
          this.max_user_count = res.data.max_user_count;
          this.videos = res.data.videos;
          this.loading = false;
        }
      );
    },
  },
};
</script>
<style lang="less" scoped>
.title {
  width: 100%;
  height: 16px;
  border-left: 4px solid #3ca7fa;
  font-size: 14px;
  line-height: 16px;
  font-weight: 600;
  color: #333333;
  box-sizing: border-box;
  padding-left: 10px;
  margin-bottom: 30px;
}
</style>
