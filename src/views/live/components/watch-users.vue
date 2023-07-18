<template>
  <div class="float-left">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex"></div>
      <div class="d-flex">
        <div>
          <el-select
            v-model="filter.is_watched"
            class="w-150px"
            placeholder="看完"
          >
            <el-option
              v-for="(item, index) in statusMapRows"
              :key="index"
              :label="item.name"
              :value="item.key"
            >
            </el-option>
          </el-select>
        </div>
        <div class="ml-10">
          <el-date-picker
            :picker-options="pickerOptions"
            v-model="filter.watched_at"
            type="daterange"
            align="right"
            unlink-panels
            range-separator="至"
            start-placeholder="看完时间-开始"
            end-placeholder="看完时间-结束"
          >
          </el-date-picker>
        </div>

        <div class="ml-10">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad" type="primary">筛选</el-button>
          <el-button @click="importexcel" type="primary">导出表格</el-button>
        </div>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="records"
          class="float-left"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          @selection-change="handleSelectionChange"
        >
          <el-table-column prop="id" sortable label="ID" width="120">
          </el-table-column>
          <el-table-column label="学员">
            <template slot-scope="scope">
              <div class="user-item d-flex" v-if="scope.row.user">
                <div class="avatar">
                  <img :src="scope.row.user.avatar" width="40" height="40" />
                </div>
                <div class="ml-10">
                  {{ scope.row.user.nick_name }}
                </div>
              </div>
              <span v-else class="c-red">学员不存在</span>
            </template>
          </el-table-column>
          <el-table-column
            property="progress"
            label="观看进度"
            sortable
            width="150"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.progress }}%</span>
            </template>
          </el-table-column>
          <el-table-column property="duration" label="学习总时长" width="150">
            <template slot-scope="scope">
              <duration-text
                v-if="!loading"
                :duration="scope.row.total_duration"
              ></duration-text>
            </template>
          </el-table-column>
          <el-table-column sortable label="开始时间" width="240">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column sortable label="看完时间" width="240">
            <template slot-scope="scope">{{
              scope.row.watched_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="看完" width="80">
            <template slot-scope="scope">
              <span class="c-red" v-if="scope.row.is_watched === 1">是</span>
              <span v-else>否</span>
            </template>
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
import Utils from "@/js/utils.js";

export default {
  components: {
    DurationText,
  },
  data() {
    return {
      course_id: this.$route.query.id,
      pagination: {
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        is_watched: -1,
        watched_at: [],
      },
      total: 0,
      loading: false,
      records: [],
      selectedRows: [],
      statusMapRows: [
        {
          name: "全部",
          key: -1,
        },
        {
          name: "未看完",
          key: 0,
        },
        {
          name: "已看完",
          key: 1,
        },
      ],
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() > Date.now();
        },
      },
    };
  },
  mounted() {
    this.getRecords();
  },
  methods: {
    paginationReset() {
      this.watched_at = null;
      this.pagination.page = 1;
      this.filter.is_watched = -1;
      this.filter.watched_at = [];
      this.getRecords();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getRecords();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getRecords();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getRecords();
    },
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getRecords();
    },
    handleSelectionChange(rows) {
      this.selectedRows = rows;
    },
    getRecords() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Course.Live.Course.Users.WatchUsers(
        this.$route.query.id,
        params
      ).then((res) => {
        this.loading = false;
        this.records = res.data.data;
        this.total = res.data.total;
      });
    },
    importexcel() {
      if (this.loading) {
        return;
      }
      this.loading = true;

      let params = {
        page: 1,
        size: this.total,
        sort: "id",
        order: "desc",
      };
      Object.assign(params, this.filter);
      this.$api.Course.Live.Course.Users.WatchUsers(
        this.$route.query.id,
        params
      ).then((res) => {
        if (res.data.total === 0) {
          this.$message.error("数据为空");
          this.loading = false;
          return;
        }

        let filename = "直播课程观看学员|" + Utils.currentDate() + ".xlsx";
        let sheetName = "sheet1";

        let data = [
          [
            "用户ID",
            "用户",
            "手机号",
            "观看进度",
            "学习总时长",
            "开始时间",
            "看完时间",
          ],
        ];
        res.data.data.forEach((item) => {
          if (typeof user === "undefined") {
            return;
          }

          data.push([
            item.user_id,
            item.user.nick_name,
            item.user.mobile,
            item.progress + "%",
            item.total_duration + "s",
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
          { wch: 20 },
          { wch: 15 },
          { wch: 20 },
          { wch: 20 },
        ];
        Utils.exportExcel(data, filename, sheetName, wscols);
        this.loading = false;
      });
    },
  },
};
</script>

<style lang="less" scoped>
.filter-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px;
  border-radius: 15px;
  margin-bottom: 15px;
  background-color: white;

  .filter-label {
    font-size: 14px;
    color: rgba(0, 0, 0, 0.7);
  }
}

.records-box {
  width: 100%;
  height: 400px;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  overflow-y: auto;
  overflow-x: hidden;

  .item {
    width: 100%;
    height: 30px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
    background: #f4fafe;
    border-radius: 4px;
    box-sizing: border-box;
    padding: 0px 10px;

    &:last-child {
      margin-bottom: 0px;
    }

    .title {
      width: 300px;
      height: 30px;
      font-size: 14px;
      font-weight: 400;
      color: #333333;
      line-height: 30px;
      white-space: nowrap;
      text-overflow: ellipsis;
      overflow: hidden;
      word-break: break-all;
    }

    .item-time {
      width: 160px;
      height: 30px;
      font-size: 14px;
      font-weight: 400;
      color: #666666;
      line-height: 30px;
      text-align: right;
    }

    .item-text {
      width: 90px;
      height: 30px;
      font-size: 14px;
      font-weight: 400;
      color: #04c877;
      line-height: 30px;
      margin-left: 10px;
      text-align: right;
    }

    .item-progress {
      width: 90px;
      height: 30px;
      font-size: 14px;
      font-weight: 400;
      color: #666666;
      line-height: 30px;
      margin-left: 10px;
      text-align: right;
    }
  }
}
</style>
