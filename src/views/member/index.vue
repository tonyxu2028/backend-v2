<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <p-button
          text="添加学员"
          p="member.store"
          @click="addMember"
          type="primary"
        >
        </p-button>
        <p-button
          text="学员批量导入"
          p="member.store"
          @click="$router.push({ name: 'MemberImport' })"
          type="primary"
          class="ml-15"
        >
        </p-button>
        <p-button
          text="批量发消息"
          p="member.message.send"
          @click="sendMessageMulti()"
          type="primary"
          class="ml-15"
        >
        </p-button>
        <p-button
          text="批量设置"
          p="member.update"
          @click="editMulti()"
          type="primary"
          class="ml-15"
        >
        </p-button>
      </div>
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.keywords"
            placeholder="完整昵称或手机号"
          ></el-input>
        </div>
        <div class="ml-10">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad" type="primary">筛选</el-button>
        </div>
        <div class="drawerMore d-flex ml-10" @click="drawer = true">
          <template v-if="showStatus">
            <img src="../../assets/img/icon-filter-h.png" />
            <span class="act">已选</span>
          </template>
          <template v-else>
            <img src="../../assets/img/icon-filter.png" />
            <span>更多</span>
          </template>
        </div>
      </div>
    </div>
    <div class="float-left mb-30 check-num">已选择{{ spids.ids.length }}项</div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          ref="multipleTable"
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="users"
          class="float-left"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" min-width="4%"></el-table-column>

          <el-table-column prop="id" sortable label="ID" min-width="6%">
          </el-table-column>

          <el-table-column label="学员昵称" min-width="15%">
            <template slot-scope="scope">
              <div class="user-item">
                <div class="avatar">
                  <img :src="scope.row.avatar" width="40" height="40" />
                </div>
                <div class="nickname">{{ scope.row.nick_name }}</div>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="手机号码" min-width="11%">
            <template slot-scope="scope">
              <span v-if="scope.row.mobile">{{ scope.row.mobile }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>

          <el-table-column label="VIP类型" min-width="8%">
            <template slot-scope="scope">
              <span v-if="scope.row.role">{{ scope.row.role.name }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>

          <el-table-column prop="credit1" sortable label="积分" min-width="8%">
          </el-table-column>

          <el-table-column label="标签" min-width="10%" show-overflow-tooltip>
            <template slot-scope="scope">
              <template v-if="scope.row.tags.length > 0">
                <el-tag
                  class="ml-5 mb-5"
                  v-for="(item, index) in scope.row.tags"
                  :key="index"
                >
                  {{ item.name }}
                </el-tag>
              </template>
              <template v-else>-</template>
            </template>
          </el-table-column>

          <el-table-column
            label="备注信息"
            min-width="9%"
            show-overflow-tooltip
          >
            <template slot-scope="scope">
              <div
                v-if="userRemark[scope.row.id]"
                v-html="userRemark[scope.row.id].remark"
              ></div>
              <span v-else>-</span>
            </template>
          </el-table-column>

          <el-table-column sortable="" label="注册时间" min-width="14%">
            <template slot-scope="scope">{{
              scope.row.created_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="账号状态" min-width="6%">
            <template slot-scope="scope">
              <span v-if="scope.row.is_lock === 1" class="c-red">·冻结</span>
              <span v-else class="c-green">·正常</span>
            </template>
          </el-table-column>
          <el-table-column
            fixed="right"
            label="操作"
            min-width="10%"
            align="right"
          >
            <template slot-scope="scope">
              <p-link
                text="详情"
                p="member.detail"
                type="primary"
                @click="detail(scope.row)"
              ></p-link>
              <el-dropdown>
                <el-link type="primary" class="el-dropdown-link ml-5">
                  更多<i class="el-icon-arrow-down el-icon--right"></i>
                </el-link>
                <el-dropdown-menu slot="dropdown">
                  <p-dropdown-item
                    text="编辑资料"
                    p="member.update"
                    type="primary"
                    @click="updateMember(scope.row.id)"
                  >
                  </p-dropdown-item>
                  <p-dropdown-item
                    text="站内消息"
                    p="member.message.send"
                    type="primary"
                    @click="sendMessage(scope.row)"
                  >
                  </p-dropdown-item>
                  <p-dropdown-item
                    :text="lockText(scope.row)"
                    p="member.update"
                    type="danger"
                    @click="lockMember(scope.row)"
                  >
                  </p-dropdown-item>
                </el-dropdown-menu>
              </el-dropdown>
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
            v-model="filter.keywords"
            placeholder="学员列表关键字"
          ></el-input>
        </div>
        <div class="j-flex mt-20">
          <el-select
            v-model="filter.role_id"
            class="w-300px"
            placeholder="VIP会员"
            clearable
          >
            <el-option
              v-for="(item, index) in filterData.roles"
              :key="index"
              :label="item.name"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>

        <div class="j-flex mt-20">
          <el-select
            v-model="filter.tag_id"
            class="w-300px"
            placeholder="学员标签"
            clearable
          >
            <el-option
              v-for="(item, index) in filterData.tags"
              :key="index"
              :label="item.name"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>
        <div class="j-flex mt-20">
          <el-date-picker
            :picker-options="pickerOptions"
            v-model="filter.created_at"
            type="daterange"
            align="right"
            unlink-panels
            range-separator="至"
            start-placeholder="注册开始日期"
            end-placeholder="注册结束日期"
          >
          </el-date-picker>
        </div>
        <div class="j-b-flex mt-30">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad" type="primary">筛选</el-button>
        </div>
      </div>
    </el-drawer>
    <el-dialog title="发消息" :visible.sync="visible" width="400px">
      <div class="d-flex">
        <el-input
          type="textarea"
          maxlength="500"
          resize="none"
          show-word-limit
          v-model="message"
          placeholder="请输入消息文本"
          class="w-100"
          rows="4"
        ></el-input>
      </div>
      <div class="j-r-flex mt-20">
        <el-button v-if="mid" @click="confirm" type="primary">确认</el-button>
        <el-button v-else @click="confirmMulti" type="primary">确认</el-button>
      </div>
    </el-dialog>
    <el-dialog title="批量修改" :visible.sync="editVisible" width="420px">
      <div class="j-flex flex-column">
        <div class="d-flex">
          <el-select @change="clearEdit" class="w-100" v-model="current">
            <el-option
              v-for="(item, index) in types"
              :key="index"
              :label="item.name"
              :value="item.key"
            >
            </el-option>
          </el-select>
        </div>
        <div class="d-flex mt-20" v-if="current === 'is_lock'">
          <label class="w-100px mr-20">是否禁止登录</label>
          <el-switch
            :key="current"
            v-model="form.is_lock"
            :active-value="1"
            :inactive-value="0"
          >
          </el-switch>
        </div>
        <template v-if="current === 'role_id'">
          <div class="d-flex mt-20">
            <label class="w-100px mr-20">设置会员</label>
            <el-select
              :key="current"
              clearable
              class="el-item"
              v-model="form.role_id"
            >
              <el-option
                v-for="(item, index) in filterData.roles"
                :key="index"
                :label="item.name"
                :value="item.id"
              >
              </el-option>
            </el-select>
          </div>
          <div class="d-flex mt-20">
            <label class="w-100px mr-20">会员到期时间</label>
            <el-date-picker
              class="el-item"
              v-model="form.role_expired_at"
              type="datetime"
              placeholder="选择日期"
              format="yyyy-MM-dd HH:mm:ss"
              value-format="yyyy-MM-dd HH:mm:ss"
              :picker-options="newPickerOptions"
            >
            </el-date-picker>
          </div>
        </template>
        <div class="d-flex mt-20" v-if="current === 'is_password_set'">
          <label class="w-100px mr-20">是否已设置密码</label>
          <el-switch
            :key="current"
            v-model="form.is_password_set"
            :active-value="1"
            :inactive-value="0"
          >
          </el-switch>
        </div>
        <div class="d-flex mt-20" v-if="current === 'is_set_nickname'">
          <label class="w-100px mr-20">是否已设置昵称</label>
          <el-switch
            :key="current"
            v-model="form.is_set_nick_name"
            :active-value="1"
            :inactive-value="0"
          >
          </el-switch>
        </div>
        <div class="d-flex mt-20" v-if="current === 'tag'">
          <label class="w-100px mr-20">设置标签</label>
          <el-select
            :key="current"
            class="el-item"
            multiple
            v-model="form.tag_ids"
          >
            <el-option
              v-for="(item, index) in filterData.tags"
              :key="index"
              :label="item.name"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>
      </div>

      <div class="j-r-flex mt-30">
        <el-button @click="editConfirmMulti" type="primary">确认</el-button>
      </div>
    </el-dialog>
    <member-dialog
      :key="updateId"
      v-if="showAddWin"
      :text="tit"
      :id="updateId"
      @close="showAddWin = false"
      @success="successEvt"
    ></member-dialog>
  </div>
</template>

<script>
import MemberDialog from "./components/member-dialog";
export default {
  components: {
    MemberDialog,
  },
  data() {
    return {
      pageName: "member-list",
      pagination: {
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        keywords: null,
        role_id: null,
        tag_id: null,
        created_at: null,
      },
      total: 0,
      loading: false,
      users: [],
      userRemark: [],
      filterData: {
        tags: [],
        roles: [],
      },
      drawer: false,
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() > Date.now();
        },
      },
      newPickerOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now();
        },
      },
      visible: false,
      editVisible: false,
      message: null,
      mid: null,
      spids: {
        ids: [],
      },
      form: {
        tag_ids: [],
        is_set_nick_name: null,
        is_password_set: null,
        role_id: null,
        role_expired_at: null,
        is_lock: null,
      },
      current: null,
      types: [
        {
          name: "批量设置会员",
          key: "role_id",
        },
        {
          name: "批量设置标签",
          key: "tag",
        },
        {
          name: "批量冻结账号",
          key: "is_lock",
        },
        // {
        //   name: "是否已设置密码",
        //   key: "is_password_set",
        // },
        // {
        //   name: "是否已设置昵称",
        //   key: "is_set_nickname",
        // },
      ],
      dialogLoading: false,
      showAddWin: false,
      tit: null,
      updateId: null,
    };
  },
  activated() {
    this.getUser();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  computed: {
    showStatus() {
      if (
        this.filter.role_id ||
        this.filter.tag_id ||
        this.filter.created_at ||
        this.filter.keywords
      ) {
        return true;
      }
      return false;
    },
  },
  methods: {
    lockText(item) {
      let text = "冻结账号";
      if (item.is_lock === 1) {
        text = "解冻账号";
      }
      return text;
    },
    addMember() {
      this.tit = "添加学员资料";
      this.updateId = null;
      this.showAddWin = true;
    },
    updateMember(id) {
      this.tit = "编辑学员资料";
      this.updateId = id;
      this.showAddWin = true;
    },
    successEvt() {
      this.showAddWin = false;
      this.paginationReset();
    },
    handleSelectionChange(val) {
      var newbox = [];
      for (var i = 0; i < val.length; i++) {
        newbox.push(val[i].id);
      }
      this.spids.ids = newbox;
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.keywords = null;
      this.filter.role_id = null;
      this.filter.tag_id = null;
      this.filter.created_at = null;
      this.getUser();
      this.drawer = false;
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getUser();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getUser();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getUser();
      this.drawer = false;
    },
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getUser();
    },
    getUser() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Member.List(params).then((res) => {
        this.loading = false;
        this.users = res.data.data.data;
        this.total = res.data.data.total;
        // 学员备注
        this.userRemark = res.data.user_remarks;

        this.filterData.tags = res.data.tags;
        this.filterData.roles = res.data.roles;
      });
    },
    detail(item) {
      this.$router.push({ name: "MemberDetail", params: { userId: item.id } });
    },
    sendMessage(item) {
      this.visible = true;
      this.mid = item.id;
    },
    editMulti() {
      if (this.spids.ids == "") {
        this.$message.error("请先勾选要批量设置的学员");
        return;
      }
      this.editVisible = true;
    },
    sendMessageMulti() {
      if (this.spids.ids == "") {
        this.$message.error("请选择需要发消息的学员");
        return;
      }
      this.visible = true;
    },
    clearEdit() {
      this.form.is_lock = null;
      this.form.tag_ids = [];
      this.form.is_set_nick_name = null;
      this.form.is_password_set = null;
      this.form.role_id = null;
      this.form.role_expired_at = null;
    },
    editConfirmMulti() {
      if (this.dialogLoading) {
        return;
      }
      if (this.form.role_id && !this.form.role_expired_at) {
        this.$message.error("请选择VIP过期时间");
        return;
      }
      if (!this.form.role_id && this.form.role_expired_at) {
        this.$message.error("请选择VIP");
        return;
      }
      this.dialogLoading = true;
      this.$api.Member.EditMulti({
        user_ids: this.spids.ids,
        field: this.current,
        value: this.current === "tag" ? null : this.form[this.current],
        role_expired_at: this.form.role_expired_at,
        tag_ids: this.form.tag_ids,
      })
        .then((res) => {
          this.dialogLoading = false;
          this.$message.success(this.$t("common.success"));
          this.clearEdit();
          this.current = null;
          this.$refs.multipleTable.clearFilter();
          this.editVisible = false;
          this.getUser();
        })
        .catch((e) => {
          this.dialogLoading = false;
          this.$message.error(e.message);
        });
    },
    confirmMulti() {
      if (this.dialogLoading) {
        return;
      }
      this.dialogLoading = true;
      this.$api.Member.SendMessageMulti({
        user_ids: this.spids.ids,
        message: this.message,
      })
        .then((res) => {
          this.dialogLoading = false;
          this.$message.success(this.$t("common.success"));
          this.message = null;
          this.mid = null;
          this.visible = false;
          this.$refs.multipleTable.clearFilter();
          this.getUser();
        })
        .catch((e) => {
          this.dialogLoading = false;
          this.visible = false;
          this.$message.error(e.message);
        });
    },
    confirm() {
      this.$api.Member.SendMessage(this.mid, {
        message: this.message,
      })
        .then((res) => {
          this.$message.success(this.$t("common.success"));
          this.message = null;
          this.mid = null;
          this.visible = false;
          this.getUser();
        })
        .catch((e) => {
          this.visible = false;
          this.$message.error(e.message);
        });
    },
    lockMember(item) {
      let text = "冻结后此账号将无法登录，确认冻结？";
      let value = 1;
      if (item.is_lock === 1) {
        text = "解冻后此账号将正常登录，确认解冻？";
        value = 0;
      }
      this.$confirm(text, "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          this.$api.Member.EditMulti({
            user_ids: [item.id],
            field: "is_lock",
            value: value,
          })
            .then((res) => {
              this.$message.success(this.$t("common.success"));
              this.getUser();
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
  },
};
</script>

<style lang="less" scoped>
.user-item {
  width: auto;
  display: flex;
  align-items: center;
  .avatar {
    margin-right: 10px;
  }
  .nickname {
    font-size: 15px;
    font-weight: normal;
  }
}
label {
  text-align: right;
}
.el-item {
  flex: 1;
}
</style>
