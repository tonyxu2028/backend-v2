<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.user_id"
            placeholder="学员ID"
          ></el-input>
        </div>
        <div class="ml-10">
          <el-button @click="paginationReset()">清空</el-button>
          <el-button @click="firstPageLoad()" type="primary"> 筛选 </el-button>
          <el-button @click="importexcel" type="primary">导出表格</el-button>
        </div>
      </div>
    </div>

    <div class="float-left">
      <el-tabs v-model="filter.status">
        <el-tab-pane
          :label="item.name"
          :name="item.key"
          v-for="(item, index) in filterData.groups"
          :key="index"
        ></el-tab-pane>
      </el-tabs>
    </div>

    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="results"
          class="float-left"
        >
          <el-table-column prop="id" label="记录ID" width="120">
          </el-table-column>
          <el-table-column label="学员" width="300">
            <template slot-scope="scope">
              <div
                v-if="scope.row.user"
                style="display: flex; flex-direction: column"
              >
                <div>{{ scope.row.user.nick_name }}</div>
                <div style="font-size: 10px; color: rgba(0, 0, 0, 0.3)">
                  ID#{{ scope.row.user_id }}
                </div>
              </div>
              <span v-else class="c-red">-</span>
            </template>
          </el-table-column>
          <el-table-column label="渠道" width="60">
            <template slot-scope="scope">
              <img
                v-if="scope.row.channel === 'alipay'"
                src="../../assets/img/ali-pay.png"
                width="30"
                height="30"
              />
              <img
                v-else-if="scope.row.channel === 'wechat'"
                src="../../assets/img/wepay.png"
                width="30"
                height="30"
              />
            </template>
          </el-table-column>
          <el-table-column label="金额" width="150">
            <template slot-scope="scope">
              <div style="display: flex; flex-direction: column">
                <div>￥{{ scope.row.amount }}</div>
                <div style="color: rgba(0, 0, 0, 0.3); font-size: 10px">
                  提现前余额：￥{{ scope.row.before_balance }}
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="150">
            <template slot-scope="scope">
              <span class="c-yellow" v-if="scope.row.status === 0"
                >· 待处理</span
              >
              <span class="c-red" v-else-if="scope.row.status === 3"
                >· 已驳回</span
              >
              <span class="c-green" v-else-if="scope.row.status === 5"
                >· 已处理</span
              >
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注"> </el-table-column>
          <el-table-column label="申请时间" width="200">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="操作" width="120">
            <template slot-scope="scope">
              <p-link
                v-if="scope.row.status === 0"
                p="addons.MultiLevelShare.withdraw.handle"
                text="处理"
                type="primary"
                @click="handleMulti(scope.row.id)"
              >
              </p-link>
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

    <el-dialog
      title="提现处理"
      :visible="showHandleWin"
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <el-form ref="form" :model="form" :rules="rules" label-width="200px">
        <el-form-item label="打款方式" prop="action">
          <el-select v-model="form.action" placeholder="请选择打款方式">
            <el-option label="走提现渠道" value="follow"></el-option>
            <el-option label="线下手动打款" value="hand"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="成功" :value="5"></el-option>
            <el-option label="驳回" :value="3"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item
          label="是否退回提现金额"
          prop="is_return"
          v-if="form.status === 3"
        >
          <el-switch
            v-model="form.is_return"
            :active-value="1"
            :inactive-value="0"
          >
          </el-switch>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="form.remark"
            class="w-400px"
            placeholder="请输入备注"
            type="textarea"
            rows="3"
          ></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="showHandleWin = false">取消</el-button>
        <el-button type="primary" @click="formValidate">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import moment from "moment";
export default {
  data() {
    return {
      pageName: "withdrawOrders-list",
      showHandleWin: false,
      pagination: {
        page: 1,
        size: 10,
      },
      filter: {
        user_id: null,
        status: "0",
        keywords: "",
      },
      filterData: {
        groups: [
          {
            name: "待处理",
            key: "0",
          },
          {
            name: "已处理",
            key: "5",
          },
          {
            name: "已驳回",
            key: "3",
          },
        ],
      },
      total: 0,
      loading: false,
      spids: {
        ids: [],
      },
      results: [],
      form: {
        action: null,
        status: null,
        remark: null,
        is_return: 1,
      },
      rules: {
        action: [
          {
            required: true,
            message: "请选择打款方式",
            trigger: "blur",
          },
        ],
        status: [
          {
            required: true,
            message: "请选择状态",
            trigger: "blur",
          },
        ],
        remark: [
          {
            required: true,
            message: "请输入备注",
            trigger: "blur",
          },
        ],
        is_return: [
          {
            required: true,
            message: "请选择是否退回提现金额",
            trigger: "blur",
          },
        ],
      },
    };
  },
  watch: {
    "filter.status"() {
      this.paginationReset();
    },
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
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.user_id = "";
      this.filter.keywords = "";
      this.getData();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter, this.pagination);
      this.$api.Order.WithdrawOrders.WithdrawOrders(params).then((res) => {
        this.loading = false;
        this.results = res.data.data;
        this.total = res.data.total;
      });
    },
    handleMulti(id) {
      this.form.status = null;
      this.form.is_return = null;
      this.form.remark = null;
      this.spids.ids = [id];
      this.showHandleWin = true;
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.submitHandle();
        }
      });
    },
    submitHandle() {
      this.$api.Order.WithdrawOrders.Submit({
        id: this.spids.ids[0],
        status: this.form.status,
        remark: this.form.remark,
        is_return: this.form.is_return,
        action: this.form.action,
      })
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.showHandleWin = false;
          this.form.status = null;
          this.form.remark = null;
          this.form.is_return = 1;
          this.getData();
        })
        .catch((e) => {
          this.$message.error(e.message);
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
      };
      Object.assign(params, this.filter);

      this.$api.Order.WithdrawOrders.WithdrawOrders(params).then((res) => {
        if (res.data.total === 0) {
          this.$message.error("数据为空");
          this.loading = false;
          return;
        }
        let filename = "余额提现.xlsx";
        let sheetName = "sheet1";

        let data = [
          [
            "学员ID",
            "学员",
            "金额",
            "收款人渠道",
            "收款人姓名",
            "收款人账号",
            "状态",
            "备注",
            "时间",
          ],
        ];
        res.data.data.forEach((item) => {
          let status;
          if (item.status === 0) {
            status = "待处理";
          } else if (item.status === 3) {
            status = "已驳回";
          } else if (item.status === 5) {
            status = "已处理";
          }
          data.push([
            item.user_id,
            item.user ? item.user.nick_name : "",
            item.amount + "元",
            item.channel,
            item.channel_name,
            item.channel_account,
            status,
            item.remark,
            item.created_at
              ? moment(item.created_at).format("YYYY-MM-DD HH:mm")
              : "",
          ]);
        });
        let wscols = [
          { wch: 10 },
          { wch: 20 },
          { wch: 15 },
          { wch: 15 },
          { wch: 20 },
          { wch: 20 },
          { wch: 15 },
          { wch: 20 },
          { wch: 20 },
        ];
        this.$utils.exportExcel(data, filename, sheetName, wscols);
        this.loading = false;
      });
    },
  },
};
</script>
