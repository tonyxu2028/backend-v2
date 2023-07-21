<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="直播课时学员"></back-bar>

    <div class="float-left">
      <div class="float-left d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.mobile"
            placeholder="学员手机号"
          ></el-input>
        </div>
        <div class="ml-10">
          <el-input
            class="w-150px"
            v-model="filter.nick_name"
            placeholder="学员昵称"
          ></el-input>
        </div>
        <div class="ml-15">
          <el-button @click="firstPageLoad" type="primary"> 筛选 </el-button>
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="exportexcel" type="primary">导出表格</el-button>
        </div>
      </div>
    </div>

    <div class="float-left mt-30" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          class="float-left"
        >
          <el-table-column prop="user_id" label="学员ID" width="120">
          </el-table-column>
          <el-table-column label="学员">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user">
                <div class="avatar">
                  <img :src="scope.row.user.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">{{ scope.row.user.nick_name }}</div>
              </div>
              <span class="c-red" v-else>学员不存在</span>
            </template>
          </el-table-column>
          <el-table-column sortable label="观看时长" width="150">
            <template slot-scope="scope">
              <duration-text
                v-if="!loading"
                :duration="scope.row.duration"
              ></duration-text>
              <span class="c-red" v-else>已删除</span>
            </template>
          </el-table-column>
          <el-table-column label="总时长" width="150">
            <template slot-scope="scope">
              <duration-text
                v-if="!loading"
                :duration="scope.row.total_duration"
              ></duration-text>
              <span class="c-red" v-else>已删除</span>
            </template>
          </el-table-column>
          <el-table-column label="看完" width="80">
            <template slot-scope="scope">
              <span class="c-green" v-if="scope.row.is_watched === 1">是</span>
              <span v-else>否</span>
            </template>
          </el-table-column>
          <el-table-column sortable label="开始时间" width="200">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column sortable label="看完时间" width="200">
            <template slot-scope="scope">{{
              scope.row.watched_at | dateFormat
            }}</template>
          </el-table-column>
        </el-table>
      </div>
      <div class="float-left mt-30 text-center">
        <el-pagination
          @size-change="paginationSizeChange"
          @current-change="paginationPageChange"
          :current-page="pagination.page"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pagination.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        >
        </el-pagination>
      </div>
    </div>
  </div>
</template>
<script>
import moment from "moment";
import DurationText from "@/components/duration-text";

export default {
  components: {
    DurationText,
  },
  data() {
    return {
      pageName: "liveVideoRecords-list",
      video_id: this.$route.query.id,
      pagination: {
        course_id: this.$route.query.course_id,
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        mobile: null,
        nick_name: null,
      },
      total: 0,
      loading: false,
      list: [],
    };
  },
  watch: {
    "$route.query.id"() {
      this.pagination.page = 1;
      this.filter.mobile = null;
      this.filter.nick_name = null;
    },
  },
  activated() {
    this.getWatchRecords();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.filter.nick_name = null;
      this.filter.mobile = null;
      this.getWatchRecords();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getWatchRecords();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getWatchRecords();
    },
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getWatchRecords();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getWatchRecords();
    },
    getWatchRecords() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      this.video_id = this.$route.query.id;
      this.pagination.course_id = this.$route.query.course_id;
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Course.Live.Course.Video.WatchUsers(this.video_id, params).then(
        (res) => {
          this.loading = false;
          this.list = res.data.data;
          this.total = res.data.total;
        }
      );
    },
    exportexcel() {
      if (this.loading) {
        return;
      }
      this.loading = true;

      let params = {
        page: 1,
        size: this.total,
      };
      this.video_id = this.$route.query.id;
      this.pagination.course_id = this.$route.query.course_id;
      Object.assign(params, this.filter);

      this.$api.Course.Live.Course.Video.WatchUsers(
        this.$route.query.id,
        params
      ).then((res) => {
        if (res.data.total === 0) {
          this.$message.error("数据为空");
          this.loading = false;
          return;
        }

        let filename = "直播课时学员记录.xlsx";
        let sheetName = "sheet1";

        let data = [
          [
            "学员ID",
            "学员",
            "手机号",
            "观看时长",
            "总时长",
            "看完",
            "开始时间",
            "结束时间",
          ],
        ];
        res.data.data.forEach((item) => {
          data.push([
            item.user_id,
            item.user.nick_name,
            item.user.mobile,
            this.durationTime(item.duration),
            this.durationTime(item.total_duration),
            item.is_watched === 1 ? "是" : "否",
            item.created_at
              ? moment(item.created_at).format("YYYY-MM-DD HH:mm")
              : "",
            item.watched_at
              ? moment(item.watched_at).format("YYYY-MM-DD HH:mm")
              : "",
          ]);
        });
        let wscols = [
          { wch: 10 },
          { wch: 20 },
          { wch: 15 },
          { wch: 15 },
          { wch: 15 },
          { wch: 15 },
          { wch: 20 },
          { wch: 20 },
        ];
        this.$utils.exportExcel(data, filename, sheetName, wscols);
        this.loading = false;
      });
    },
    durationTime(duration) {
      let hour = parseInt(duration / 3600);
      let minute = parseInt((duration - hour * 3600) / 60);
      let second = duration - hour * 3600 - minute * 60;
      if (hour === 0 && minute === 0 && second === 0) {
        return null;
      }
      if (hour === 0) {
        hour = "";
      } else {
        hour = hour + ":";
      }
      if (minute < 10) {
        minute = "0" + minute;
      }
      if (second < 10) {
        second = "0" + second;
      }
      return hour + minute + ":" + second;
    },
  },
};
</script>
