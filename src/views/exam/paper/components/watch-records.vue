<template>
  <div class="float-left">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <el-button @click="exportexcel" type="primary">导出表格</el-button>
      </div>
      <div class="d-flex">
        <div>
          <el-select class="w-150px" placeholder="状态" v-model="filter.status">
            <el-option
              v-for="(item, index) in filterData.statusMap"
              :key="index"
              :label="item.text"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>
        <div class="ml-10">
          <el-button @click="paginationReset()">清空</el-button>
          <el-button @click="firstPageLoad()" type="primary"> 筛选 </el-button>
        </div>
        <div class="drawerMore d-flex ml-10" @click="drawer = true">
          <template v-if="showStatus">
            <img src="@/assets/img/icon-filter-h.png" />
            <span class="act">已选</span>
          </template>
          <template v-else>
            <img src="@/assets/img/icon-filter.png" />
            <span>更多</span>
          </template>
        </div>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          class="float-left"
        >
          <el-table-column prop="id" sortable label="ID" width="120">
          </el-table-column>
          <el-table-column prop="user_id" sortable label="学员ID" width="120">
          </el-table-column>
          <el-table-column label="学员" width="300">
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
          <el-table-column label="得分" property="score" sortable width="150">
            <template slot-scope="scope">
              <span v-if="scope.row.status === 2">{{ scope.row.score }}分</span>
            </template>
          </el-table-column>
          <el-table-column label="用时" width="150">
            <template slot-scope="scope">
              <duration-text
                v-if="!loading && scope.row.status === 2"
                :duration="scope.row.used_seconds"
              ></duration-text>
            </template>
          </el-table-column>
          <el-table-column prop="status_text" label="状态">
            <template slot-scope="scope">
              <el-tag type="info" v-if="scope.row.status === 0">未开始</el-tag>
              <el-tag type="primary" v-else-if="scope.row.status === 1"
                >考试中</el-tag
              >
              <el-tag type="success" v-else-if="scope.row.status === 2"
                >已结束</el-tag
              >
              <el-tag type="warning" v-else-if="scope.row.status === 3"
                >阅卷中</el-tag
              >
            </template>
          </el-table-column>
          <el-table-column label="开始时间" sortable width="200">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="交卷时间" sortable width="200">
            <template slot-scope="scope">{{
              scope.row.submit_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="100">
            <template slot-scope="scope">
              <p-link
                v-if="scope.row.status === 3"
                text="阅卷"
                p="addons.Paper.paper.userPaper.submit"
                type="primary"
                @click="
                  $router.push({
                    name: 'ExamPaperScore',
                    query: {
                      id: id,
                      user_paper_id: scope.row.id,
                    },
                  })
                "
                class="ml-5"
              ></p-link>
              <p-link
                text="查看"
                p="addons.Paper.paper.userPaper.render"
                type="primary"
                @click="
                  $router.push({
                    name: 'ExamPaperShow',
                    query: {
                      id: scope.row.paper_id,
                      pid: scope.row.id,
                    },
                  })
                "
                class="ml-5"
              ></p-link>
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
    <el-drawer :size="360" :visible.sync="drawer" :with-header="false">
      <div class="n-padding-box">
        <div class="tit flex">更多筛选</div>
        <div class="j-flex">
          <el-input
            class="w-300px"
            v-model="filter.user_id"
            placeholder="学员ID"
          ></el-input>
        </div>
        <div class="j-flex mt-20">
          <el-select class="w-300px" placeholder="状态" v-model="filter.status">
            <el-option
              v-for="(item, index) in filterData.statusMap"
              :key="index"
              :label="item.text"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>
        <div class="j-flex mt-20">
          <el-date-picker
            class="w-300px"
            :picker-options="pickerOptions"
            v-model="filter.created_at"
            type="daterange"
            align="right"
            unlink-panels
            range-separator="至"
            start-placeholder="考试开始时间-起始"
            end-placeholder="考试开始时间-结束"
          >
          </el-date-picker>
        </div>
        <div class="j-flex mt-20">
          <el-date-picker
            class="w-300px"
            :picker-options="pickerOptions"
            v-model="filter.submit_at"
            type="daterange"
            align="right"
            unlink-panels
            range-separator="至"
            start-placeholder="交卷时间-起始"
            end-placeholder="交卷时间-结束"
          >
          </el-date-picker>
        </div>
        <div class="j-b-flex mt-30">
          <el-button @click="paginationReset()">清空</el-button>
          <el-button @click="firstPageLoad()" type="primary"> 筛选 </el-button>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script>
import moment from "moment";
import DurationText from "@/components/duration-text";

export default {
  components: {
    DurationText,
  },
  props: ["id"],
  data() {
    return {
      pageName: "paperRecord-list",
      pagination: {
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        user_id: null,
        status: -1,
        created_at: null,
        submit_at: null,
      },
      total: 0,
      loading: false,
      list: [],
      filterData: {
        statusMap: [],
      },
      config: {
        token: this.$utils.getToken(),
      },
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() > Date.now();
        },
      },
      drawer: false,
    };
  },
  watch: {
    "$route.query.id"() {
      this.pagination.page = 1;
      this.filter.user_id = null;
      this.filter.status = -1;
      this.filter.submit_at = null;
      this.filter.created_at = null;
    },
  },
  computed: {
    showStatus() {
      if (
        this.filter.user_id ||
        this.filter.status !== -1 ||
        this.filter.submit_at ||
        this.filter.created_at
      ) {
        return true;
      }
      return false;
    },
  },
  mounted() {
    this.getResults();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    firstPageLoad() {
      this.pagination.page = 1;
      this.getResults();
      this.drawer = false;
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.user_id = null;
      this.filter.status = -1;
      this.filter.submit_at = null;
      this.filter.created_at = null;
      this.getResults();
      this.drawer = false;
    },
    paginationSizeChange(size) {
      this.pagination.size = size;
      this.getResults();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getResults();
    },
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getResults();
    },
    getResults() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter, this.pagination);
      this.$api.Exam.Paper.Userpaper(this.id, params).then((res) => {
        this.loading = false;
        this.list = res.data.data.data;
        this.total = res.data.data.total;

        let statusMap = [
          {
            text: "全部",
            id: -1,
          },
        ];
        statusMap.push(...res.data.statusMap);
        this.filterData.statusMap = statusMap;
      });
    },
    destory(item) {
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          //点击确定按钮的操作
          if (this.loading) {
            return;
          }
          this.loading = true;
          this.$api.Exam.Paper.Destory(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.getResults();
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
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
      Object.assign(params, this.filter);

      this.$api.Exam.Paper.Userpaper(this.id, params).then((res) => {
        if (res.data.data.total === 0) {
          this.$message.error("数据为空");
          this.loading = false;
          return;
        }

        let filename = "考试卷考试记录.xlsx";
        let sheetName = "sheet1";

        let data = [
          [
            "学员ID",
            "学员",
            "手机号",
            "得分",
            "用时",
            "状态",
            "开始时间",
            "交卷时间",
          ],
        ];
        res.data.data.data.forEach((item) => {
          data.push([
            item.user_id,
            item.user.nick_name,
            item.user.mobile,
            item.score + "分",
            this.durationTime(item.used_seconds),
            item.status_text,
            item.created_at
              ? moment(item.created_at).format("YYYY-MM-DD HH:mm")
              : "",
            item.submit_at
              ? moment(item.submit_at).format("YYYY-MM-DD HH:mm")
              : "",
          ]);
        });
        let wscols = [
          { wch: 10 },
          { wch: 20 },
          { wch: 15 },
          { wch: 10 },
          { wch: 15 },
          { wch: 10 },
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
