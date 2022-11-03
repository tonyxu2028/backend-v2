<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="新建兑换活动"></back-bar>
    <div class="float-left">
      <el-form ref="form" :model="form" :rules="rules" label-width="200px">
        <div class="title mt-10">兑换活动基本信息</div>
        <el-form-item label="活动名称" prop="name">
          <el-input
            v-model="form.name"
            class="w-300px"
            placeholder="请填写活动名称"
          ></el-input>
        </el-form-item>
        <el-form-item label="活动开始时间" prop="start_at">
          <div class="d-flex">
            <div>
              <el-date-picker
                v-model="form.start_at"
                type="datetime"
                format="yyyy-MM-dd HH:mm"
                value-format="yyyy-MM-dd HH:mm"
                placeholder="请选择日期"
                style="width: 300px"
              >
              </el-date-picker>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="活动结束时间" prop="end_at">
          <div class="d-flex">
            <div>
              <el-date-picker
                v-model="form.end_at"
                type="datetime"
                format="yyyy-MM-dd HH:mm"
                value-format="yyyy-MM-dd HH:mm"
                placeholder="请选择日期"
                style="width: 300px"
              >
              </el-date-picker>
            </div>
          </div>
        </el-form-item>
        <div class="title mt-30">兑换活动包含商品</div>
        <div class="float-left mb-30">
          <p-button
            text="添加商品"
            p="addons.CodeExchanger.activity.store"
            @click="showSelectResourceCoursesWin = true"
            type="primary"
          >
          </p-button>
          <select-resource
            :selectedVod="coursesVodId"
            :selectedLive="coursesLiveId"
            :selectedBook="bookId"
            :selectedPaper="paperId"
            :selectedMockPaper="mockPaperId"
            :selectedPractice="practiceId"
            :selectedVip="vipId"
            type="CodeExchanger"
            :show="showSelectResourceCoursesWin"
            @close="showSelectResourceCoursesWin = false"
            @change="changeCourses"
            enabled-resource="vod,live,book,paper,mock_paper,practice,vip"
          ></select-resource>
        </div>
        <div class="float-left">
          <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="coursesData"
            class="float-left"
            :row-class-name="tableRowClassName"
          >
            <el-table-column label="包含商品" min-width="53%">
              <template slot-scope="scope">
                <template v-if="scope.row.type === 'book'">
                  <thumb-bar
                    :value="scope.row.thumb"
                    :width="90"
                    :height="120"
                    :title="scope.row.title"
                  ></thumb-bar>
                </template>
                <template
                  v-else-if="
                    scope.row.type === 'paper' ||
                    scope.row.type === 'mock_paper' ||
                    scope.row.type === 'practice'
                  "
                >
                  <thumb-bar
                    :value="require('@/assets/img/default-paper.png')"
                    :width="120"
                    :height="90"
                    :title="scope.row.title"
                  ></thumb-bar>
                </template>
                <template v-else-if="scope.row.type === 'vip'">
                  <thumb-bar
                    :value="require('@/assets/img/default-vip.png')"
                    :width="120"
                    :height="90"
                    :title="scope.row.title"
                  ></thumb-bar>
                </template>
                <template v-else>
                  <thumb-bar
                    :value="scope.row.thumb"
                    :width="120"
                    :height="90"
                    :title="scope.row.title"
                  ></thumb-bar>
                </template>
              </template>
            </el-table-column>
            <el-table-column label="商品类型" min-width="20%">
              <template slot-scope="scope">
                <span v-if="scope.row.type === 'vod'">录播课程</span>
                <span v-else-if="scope.row.type === 'live'">直播课程</span>
                <span v-else-if="scope.row.type === 'book'">电子书</span>
                <span v-else-if="scope.row.type === 'paper'">考试</span>
                <span v-else-if="scope.row.type === 'mock_paper'">模拟卷</span>
                <span v-else-if="scope.row.type === 'practice'">练习</span>
                <span v-else-if="scope.row.type === 'vip'">VIP会员</span>
              </template>
            </el-table-column>
            <el-table-column label="单品价格" min-width="21%">
              <template slot-scope="scope">
                <span v-if="scope.row.charge === 0">免费</span>
                <span v-else>￥{{ scope.row.charge }}</span>
              </template>
            </el-table-column>
            <el-table-column
              fixed="right"
              label="操作"
              align="right"
              min-width="6%"
            >
              <template slot-scope="scope">
                <p-link
                  text="删除"
                  class="ml-5"
                  p="addons.CodeExchanger.activity.update"
                  type="danger"
                  @click="delCourses(scope.row.row_index)"
                ></p-link>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-form>

      <div class="bottom-menus">
        <div class="bottom-menus-box">
          <div>
            <el-button @click="formValidate" :loading="loading" type="primary"
              >保存</el-button
            >
          </div>
          <div class="ml-24">
            <el-button @click="$router.back()">取消</el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import SelectResource from "@/components/select-resources/multiIndex";
export default {
  components: {
    SelectResource,
  },
  data() {
    return {
      form: {
        name: null,
        start_at: null,
        end_at: null,
        relate_data: [],
      },
      rules: {
        name: [
          {
            required: true,
            message: "活动名不能为空",
            trigger: "blur",
          },
        ],
        start_at: [
          {
            required: true,
            message: "请选择活动开始时间",
            trigger: "blur",
          },
        ],
        end_at: [
          {
            required: true,
            message: "请选择活动结束时间",
            trigger: "blur",
          },
        ],
      },
      loading: false,
      coursesData: [],
      showSelectResourceCoursesWin: false,
    };
  },
  computed: {
    coursesVodId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "vod") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    coursesLiveId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "live") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    paperId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "paper") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    bookId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "book") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    mockPaperId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "mock_paper") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    practiceId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "practice") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
    vipId() {
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          if (this.coursesData[i].type === "vip") {
            params.push(this.coursesData[i].id);
          }
        }
      }
      return params;
    },
  },
  mounted() {},
  methods: {
    tableRowClassName({ row, rowIndex }) {
      row.row_index = rowIndex;
    },
    changeCourses(data) {
      if (data[0].type === "vip") {
        if (this.coursesData.length > 0) {
          let key = null;
          for (let i = 0; i < this.coursesData.length; i++) {
            if (this.coursesData[i].type === "vip") {
              this.coursesData.splice(i, 1);
            }
          }
          this.coursesData = this.coursesData.concat(data);
        } else {
          this.coursesData = this.coursesData.concat(data);
        }
      } else {
        this.coursesData = this.coursesData.concat(data);
      }
      this.showSelectResourceCoursesWin = false;
    },
    delCourses(index) {
      this.coursesData.splice(index, 1);
    },

    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    confirm() {
      if (this.loading) {
        return;
      }
      if (this.coursesData.length === 0) {
        this.$message.warning("请添加兑换活动包含商品");
        return;
      }
      let params = [];
      if (this.coursesData.length > 0) {
        for (let i = 0; i < this.coursesData.length; i++) {
          let type = this.coursesData[i].type;
          let item = {
            sign: type,
            id: this.coursesData[i].id,
            name: this.coursesData[i].title,
            thumb: this.coursesData[i].thumb,
            charge: this.coursesData[i].charge,
          };
          params.push(item);
        }
      }
      this.form.relate_data = JSON.stringify(params);
      this.loading = true;
      this.$api.CodeExchanger.Store(this.form)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.back();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
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
  padding-left: 10px;
  margin-bottom: 30px;
}
</style>
